#!/bin/bash

CLIENT_WS_DIR=/home/imas/catalog_qt_2/client/catalog-ws-client/
CLIENT_WS_JAR=${CLIENT_WS_DIR}/target/catalogAPI.jar
CLIENT_WS_PROPERTIES=${CLIENT_WS_DIR}/src/main/resources/service-login.properties

wait-for-it server:8080 --timeout=0

java -jar ${CLIENT_WS_JAR} \
    -keyCloakServiceLogin \
    --realm-settings-file ${CLIENT_WS_PROPERTIES} 

exec java -jar ${CLIENT_WS_JAR} \
    -startUpdateProcess \
    --url http://server:8080 \
    --scheme mdsplus \
    --run-as-service \
    --slice-limit 100
