#!/bin/bash

cd imas-watchdog

wait-for-it server:8080 --timeout=0

INI_FILE=imasdb.ini

if [ -z "$DISABLE_ACCESS_TOKEN" ]; then

  java \
    -jar /catalog_qt_2/client/catalog-ws-client/target/catalogAPI.jar \
    -keyCloakServiceLogin \
    --realm-settings-file /docker-entrypoint-properties.d/service-login.properties

else
  INI_FILE=imasdb-token.ini
fi

exec ./main.py --config ${INI_FILE} --verbose
