#! /bin/bash
CATALOGQT_BRANCH=develop
IMAS_WATCHDOG_BRANCH=master

DEFAULT_CATALOGQT_REPO="--single-branch --branch ${CATALOGQT_BRANCH} https://gforge-next.eufus.eu/git/catalog_qt_2"
DEFAULT_IMAS_WATCHDOG_REPO="--single-branch --branch ${IMAS_WATCHDOG_BRANCH} https://github.com/tzok/imas-watchdog"

function helpexit {
  echo
  echo 'syntax: ./build.sh [-catalogqt-repo="catalog_qt2 repo with branch if needed"]'
  echo '                   [-dashboard-repo="dashboard repo with branch if needed"]'
  echo '                   [-imas-watchdog-repo="imas-watchdog repo with branch if needed"]'
  echo '                   [-help]'
  echo
  echo
  echo '-catalogqt-repo     - you can pass location of repository and specify branch'
  echo "                     example: -catalogqt-repo=\"${DEFAULT_CATALOGQT_REPO}\""
  echo
  echo '-imas-watchdog-repo - you can pass location of repository and specify branch'
  echo "                      example: -imas-watchdog-repo=\"${DEFAULT_IMAS_WATCHDOG_REPO}\""
  echo
  echo '-force              - perform git-checkout and git-pull, even for existing directories'
  echo '                      (beware: this option will cause full image rebuilt without cache)'
  echo
  echo '-no-cache           - do not use Docker cache when building images'
  echo
  echo '-help/--help        - prints help and quits'
  echo
  echo
  exit 1
}

for i in "$@"
do
case $i in
    -catalogqt-repo=*)
      CATALOGQT_REPO="${i#*=}"
      shift # go to next arg=val
      ;;
    -imas-watchdog-repo=*)
      IMAS_WATCHDOG_REPO="${i#*=}"
      shift # go to next arg=val
      ;;
    -h)
      helpexit
      ;;
    -help)
      helpexit
      ;;
    -force)
      FORCE=1
      shift
      ;;
    -no-cache)
      BUILD_ARGS=--no-cache
      shift
      ;;
    *)
      echo "Unknow argument: $i"
      ;;
esac
done

CATALOGQT_REPO="${CATALOGQT_REPO:-$DEFAULT_CATALOGQT_REPO}"
IMAS_WATCHDOG_REPO="${IMAS_WATCHDOG_REPO:-$DEFAULT_IMAS_WATCHDOG_REPO}"

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

if [[ ! -d imas-watchdog ]]; then
    echo 'Retrieving imas-watchdog - make sure to provide correct login/password'
    git clone $IMAS_WATCHDOG_REPO
else
    if [[ -n "${FORCE}" ]]; then
        echo 'Updating imas-watchdog - make sure to provide correct login/password'
        cd imas-watchdog
        git checkout ${IMAS_WATCHDOG_BRANCH}
        git pull
        cd ..
    fi
    echo "Using existing imas-watchdog directory (git describe => $(cd imas-watchdog; git describe))"
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

# use cache, tag watchdog
docker build \
    --target watchdog \
    --tag catalogqt/watchdog \
    .

