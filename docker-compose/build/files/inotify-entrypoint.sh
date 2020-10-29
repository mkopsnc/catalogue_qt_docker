#! /bin/bash
java \
    -jar /catalog_qt_2/client/catalog-ws-client/target/catalogAPI.jar \
    -keyCloakServiceLogin \
    --realm-settings-file /docker-entrypoint-properties.d/service-login.properties
exec "$@"
