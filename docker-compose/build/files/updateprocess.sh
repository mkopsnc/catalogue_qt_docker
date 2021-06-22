#!/bin/bash

CLIENT_WS_DIR=/catalog_qt_2/client/catalog-ws-client/
CLIENT_WS_JAR=${CLIENT_WS_DIR}/target/catalogAPI.jar
CLIENT_WS_PROPERTIES=${CLIENT_WS_DIR}/src/main/resources/service-login.properties

wait-for-it server:8080 --timeout=0

if [ -z "$DISABLE_ACCESS_TOKEN" ]; then

  java -jar ${CLIENT_WS_JAR} \
    -keyCloakServiceLogin \
    --realm-settings-file ${CLIENT_WS_PROPERTIES} 
  
  exec java -jar ${CLIENT_WS_JAR} \
    -startUpdateProcess \
    --url http://server:8080 \
    --scheme mdsplus \
    --run-as-service \
    --slice-limit 100
else

  echo "DISABLE_ACCESS_TOKEN is set - access token will not be generated"

  exec java -jar ${CLIENT_WS_JAR} \
    -startUpdateProcess \
    --url http://server:8080 \
    --scheme mdsplus \
    --run-as-service \
    --disable-access-token \
    --slice-limit 100

fi


