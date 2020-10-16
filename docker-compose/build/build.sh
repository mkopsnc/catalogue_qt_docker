#! /bin/bash
docker login rhus-71.man.poznan.pl
docker pull rhus-71.man.poznan.pl/imas/ual
docker tag rhus-71.man.poznan.pl/imas/ual imas/ual

if [[ ! -d catalog_qt_2 ]]; then
    git clone --single-branch --branch develop https://gforge6.eufus.eu/git/catalog_qt_2
fi

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
