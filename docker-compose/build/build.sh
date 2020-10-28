#! /bin/bash

function helpexit {
  echo ""
  echo 'syntax: ./build.sh [-catalogqt-repo="catalog_qt2 repo with branch if needed"]'
  echo '                   [-dashboard-repo="dashboard repo with branch if needed"]'
  echo '                   [-imas-inotify-repo="imas-notify repo with branch if needed"]'
  echo '                   [-help]'
  echo ""
  echo ""
  echo "-catalogqt-repo    - you can pass location of repository and specify branch"
  echo "                     example: -catalogqt-repo=\"--single-branch --branch v1.3 \\"
  echo "                              https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2\""
  echo ""
  echo "-dashboard-repo    - you can pass location of repository and specify branch"
  echo "                     example: -dashboard-repo=\"--single-branch --branch v1.3 \\"
  echo "                              https://gitlab.com/fair-for-fusion/demonstrator-dashboard\""
  echo ""
  echo "-imas-inotify-repo - you can pass location of repository and specify branch"
  echo "                     example: -imas-inotify-repo=\"--single-branch --branch 0.4 \\"
  echo "                              https://github.com/tzok/imas-inotify\""
  echo ""
  echo "-help/--help       - prints help and quits"
  echo ""
  echo ""
  exit 1
}

CATALOG_QT_REPO="--single-branch --branch v1.3 https://gforge6.eufus.eu/git/catalog_qt_2"
DASHBOARD_REPO="--single-branch --branch v1.3 https://gitlab.com/fair-for-fusion/demonstrator-dashboard"
IMAS_INOTIFY_REPO="--single-branch --branch 0.4 https://github.com/tzok/imas-inotify"

for i in "$@"
do
case $i in
    # common arguments
    -help)
    helpexit
    shift
    ;;
    --help)
    helpexit
    shift
    ;;
    -catalogqt-repo=*)
    CATALOG_QT_REPO="${i#*=}"
    shift # past argument=value
    ;;
    -dashboard-repo=*)
    DASHBOARD_REPO="${i#*=}"
    shift # past argument=value
    ;;
    -imas-notify-repo=*)
    IMAS_INOTIFY_REPO="${i#*=}"
    shift # past argument=value
    ;;
    *)
    # unknown option
    ;;
esac
done

echo "Retrieving imas/ual image from rhus-71.man.poznan.pl - make sure to provide correct login/password"
docker login rhus-71.man.poznan.pl
docker pull rhus-71.man.poznan.pl/imas/ual
docker tag rhus-71.man.poznan.pl/imas/ual imas/ual

echo "Retrieving catalog_qt_2 - make sure to provide correct login/password"
if [[ ! -d catalog_qt_2 ]]; then
    git clone $CATALOG_QT_REPO
fi

echo "Retrieving demonstrator dashboard - make sure to provide correct login/password"
if [[ ! -d demonstrator-dashboard ]]; then
    git clone $DASHBOARD_REPO
fi

echo "Retrieving imas-inotify - make sure to provide correct login/password"
if [[ ! -d imas-inotify ]]; then
    git clone $IMAS_INOTIFY_REPO
fi

exit 1

docker build \
    --target updateprocess \
    --tag catalogqt/updateprocess \
    .

docker build \
    --target server \
    --tag catalogqt/server \
    .

docker build \
    --target db \
    --tag catalogqt/db \
    .

docker build \
    --target inotify \
    --tag catalogqt/inotify \
    .

docker build \
    --target dashboard \
    --tag catalogqt/dashboard \
    .
