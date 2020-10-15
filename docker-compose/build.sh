#! /bin/bash

docker build \
    --target updateprocess \
    --tag catalogqt/updateprocess \
    .

docker build \
    --target catalog_qt_server \
    --tag catalogqt/server \
    .

docker build \
    --target db \
    --tag catalogqt/db \
    .
