#! /bin/bash
CATALOGQT_BRANCH=master
DASHBOARD_BRANCH=psnc/develop
IMAS_INOTIFY_BRANCH=develop

DEFAULT_CATALOGQT_REPO="--single-branch --branch ${CATALOGQT_BRANCH} https://gforge6.eufus.eu/git/catalog_qt_2"
DEFAULT_DASHBOARD_REPO="--single-branch --branch ${DASHBOARD_BRANCH} https://gitlab.com/fair-for-fusion/demonstrator-dashboard"
DEFAULT_IMAS_INOTIFY_REPO="--single-branch --branch ${IMAS_INOTIFY_BRANCH} https://github.com/tzok/imas-inotify"

function helpexit {
  echo
  echo 'syntax: ./build.sh [-catalogqt-repo="catalog_qt2 repo with branch if needed"]'
  echo '                   [-dashboard-repo="dashboard repo with branch if needed"]'
  echo '                   [-imas-inotify-repo="imas-notify repo with branch if needed"]'
  echo '                   [-help]'
  echo
  echo
  echo '-catalogqt-repo    - you can pass location of repository and specify branch'
  echo "                     example: -catalogqt-repo=\"${DEFAULT_CATALOGQT_REPO}\""
  echo
  echo '-dashboard-repo    - you can pass location of repository and specify branch'
  echo "                     example: -dashboard-repo=\"${DEFAULT_DASHBOARD_REPO}\""
  echo
  echo '-imas-inotify-repo - you can pass location of repository and specify branch'
  echo "                     example: -imas-inotify-repo=\"${DEFAULT_IMAS_INOTIFY_REPO}\""
  echo
  echo '-force             - perform git-checkout and git-pull, even for existing directories'
  echo '                     (beware: this option will cause full image rebuilt without cache)'
  echo
  echo '-no-cache          - do not use Docker cache when building images'
  echo
  echo '-help/--help       - prints help and quits'
  echo
  echo
  exit 1
}

options=$(getopt --alternative --options h --longoptions force,help,no-cache,catalogqt-repo:,dashboard-repo:,imas-inotify-repo: -- "$@")
eval set -- "${options}"

while :; do
    case $1 in
        --catalogqt-repo)
            CATALOGQT_REPO="$2"
            shift 2
            ;;
        --dashboard-repo)
            DASHBOARD_REPO="$2"
            shift 2
            ;;
        --imas-inotify-repo)
            IMAS_INOTIFY_REPO="$2"
            shift 2
            ;;
        -h|--help)
            helpexit
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --no-cache)
            BUILD_ARGS=--no-cache
            shift
            ;;
        --)
            break
            ;;
    esac
done

CATALOGQT_REPO="${CATALOGQT_REPO:-$DEFAULT_CATALOGQT_REPO}"
DASHBOARD_REPO="${DASHBOARD_REPO:-$DEFAULT_DASHBOARD_REPO}"
IMAS_INOTIFY_REPO="${IMAS_INOTIFY_REPO:-$DEFAULT_IMAS_INOTIFY_REPO}"

echo 'Retrieving imas/ual image from rhus-71.man.poznan.pl - make sure to provide correct login/password'
docker login rhus-71.man.poznan.pl
docker pull rhus-71.man.poznan.pl/imas/ual
docker tag rhus-71.man.poznan.pl/imas/ual imas/ual

if [[ ! -d catalog_qt_2 ]]; then
    echo "Retrieving catalog_qt_2 - make sure to provide correct login/password"
    git clone $CATALOGQT_REPO
else
    if [[ -n "${FORCE}" ]]; then
        echo "Updating catalog_qt_2 - make sure to provide correct login/password"
        cd catalog_qt_2
        git checkout ${CATALOGQT_BRANCH}
        git pull
        cd ..
    fi
    echo "Using catalog_qt_2 directory (git describe => $(cd catalog_qt_2; git describe))"
fi

if [[ ! -d demonstrator-dashboard ]]; then
    echo 'Retrieving demonstrator dashboard - make sure to provide correct login/password'
    git clone $DASHBOARD_REPO
else
    if [[ -n "${FORCE}" ]]; then
        echo 'Updating demonstrator dashboard - make sure to provide correct login/password'
        cd demonstrator-dashboard
        git checkout ${DASHBOARD_BRANCH}
        git pull
        cd ..
    fi
    echo "Using demonstrator-dashboard directory (git describe => $(cd demonstrator-dashboard; git describe))"
fi

if [[ ! -d imas-inotify ]]; then
    echo 'Retrieving imas-inotify - make sure to provide correct login/password'
    git clone $IMAS_INOTIFY_REPO
else
    if [[ -n "${FORCE}" ]]; then
        echo 'Updating imas-inotify - make sure to provide correct login/password'
        cd imas-inotify
        git checkout ${IMAS_INOTIFY_BRANCH}
        git pull
        cd ..
    fi
    echo "Using existing imas-inotify directory (git describe => $(cd imas-inotify; git describe))"
fi

# build all stages
docker build \
    $BUILD_ARGS \
    .

# use cache, tag updateprocess
docker build \
    --target updateprocess \
    --tag catalogqt/updateprocess \
    .

# use cache, tag server
docker build \
    --target server \
    --tag catalogqt/server \
    .

# use cache, tag db
docker build \
    --target db \
    --tag catalogqt/db \
    .

# use cache, tag inotify
docker build \
    --target inotify \
    --tag catalogqt/inotify \
    .

# use cache, tag dashboard
docker build \
    --target dashboard \
    --tag catalogqt/dashboard \
    .
