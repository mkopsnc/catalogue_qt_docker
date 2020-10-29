#!/bin/bash
java \
    -jar /catalog_qt_2/client/catalog-ws-client/target/catalogAPI.jar \
    -keyCloakServiceLogin \
    --realm-settings-file /docker-entrypoint-properties.d/service-login.properties

while :; do
    echo 'Trying to connect to server:8080...'
    curl -s -o /dev/null server:8080
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 3
done

cd imas-inotify
exec ./imas-inotify.py --verbose
