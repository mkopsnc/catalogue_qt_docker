#!/bin/bash

CLIENT_WS_DIR=/catalog_qt_2/client/catalog-ws-client/
CLIENT_WS_JAR=${CLIENT_WS_DIR}/target/catalogAPI.jar
CLIENT_WS_PROPERTIES=${CLIENT_WS_DIR}/src/main/resources/service-login.properties

wait-for-it server:8080 --timeout=0

DISABLE_ACCESS_TOKEN_ARG=""

if [ -z "$DISABLE_ACCESS_TOKEN" ]; then

  java -jar ${CLIENT_WS_JAR} \
    -keyCloakServiceLogin \
    --realm-settings-file ${CLIENT_WS_PROPERTIES} 

else
  if [[ "${DISABLE_ACCESS_TOKEN}" == "true" ]]; then
    echo "DISABLE_ACCESS_TOKEN environment variable is set - access token will not be generated"
    DISABLE_ACCESS_TOKEN_ARG="--disable-access-token"
  fi
fi


DEBUG_UPDATE_PROCESS_JDWP=""

if [ ! -z "$DEBUG_UPDATE_PROCESS" ]; then
  if [[ "${DEBUG_UPDATE_PROCESS}" == "true" ]]; then
    DEBUG_UPDATE_PROCESS_JDWP="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32888"
  fi
fi

export LOG4J_FORMAT_MSG_NO_LOOKUPS=true

exec java ${DEBUG_UPDATE_PROCESS_JDWP} -jar ${CLIENT_WS_JAR} \
    -startUpdateProcess \
    --url http://server:8080 \
    --scheme mdsplus \
    --run-as-service \
    ${DISABLE_ACCESS_TOKEN_ARG} \
    --slice-limit 100

