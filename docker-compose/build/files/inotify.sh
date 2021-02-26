#!/bin/bash
java \
    -jar /catalog_qt_2/client/catalog-ws-client/target/catalogAPI.jar \
    -keyCloakServiceLogin \
    --realm-settings-file /docker-entrypoint-properties.d/service-login.properties

cd imas-inotify

wait-for-it server:8080 --timeout=0

exec ./imas-inotify.py --verbose
