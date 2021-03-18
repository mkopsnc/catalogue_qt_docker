#!/bin/bash

WRAPPER_CMD=$(readlink -m $0)
WRAPPER_CMD_DIR=$(dirname ${WRAPPER_CMD})

cd ${WRAPPER_CMD_DIR}

DD_VER=`ls -1 /opt/imas/core/IMAS | head -1 | cut -f1 -d'-'`
AL_VER=`ls -1 /opt/imas/core/IMAS | head -1 | cut -f2 -d'-'`
CLIENT_WS_DIR=/home/imas/opt/catalog_qt_2/client/catalog-ws-client
CLIENT_WS_JAR=${CLIENT_WS_DIR}/target/catalogAPI.jar
CLIENT_WS_PROPERTIES=${CLIENT_WS_DIR}/src/main/resources/service-login.properties

export LD_LIBRARY_PATH=/home/imas/imas/core/IMAS/${DD_VER}-${AL_VER}/lib
export CLASSPATH=/home/imas/imas/core/IMAS/${DD_VER}-${AL_VER}/jar/imas.jar:/usr/share/java/saxon9he.jar
export IMAS_PREFIX=/home/imas/imas/core/IMAS/${DD_VER}-${AL_VER}
export IMAS_VERSION=${DD_VER}
export IMAS_HOME=/home/imas/imas
export ids_path=/home/imas/imas/core/IMAS/${DD_VER}-${AL_VER}/models/mdsplus
export UAL_VERSION=${AL_VER}

loop=1
tries=10

while [ $loop == 1 ]; do
  curl -s http://localhost:8080 > /dev/null 2>&1
  retVal=$?

  if [ $retVal -ne 0 ]; then
    sleep 10
    echo "Starting Update Process - failed to connect to Catalog QT server. Trying again in 10 seconds."
    tries=$((tries-1))
    if [ $tries == 0 ]; then
      echo "Starting Update Process - failed to connect to Catalog QT server. Quiting after 10 retries."
      exit 1
    fi
  else
    loop=0
  fi
done

java -jar ${CLIENT_WS_JAR} \
    -keyCloakServiceLogin \
    --realm-settings-file ${CLIENT_WS_PROPERTIES}

UPDATE_PROCESS_JDWP=""

if [ ! -z "$DEBUG_UPDATE_PROCESS" ]; then
  if [[ "${DEBUG_UPDATE_PROCESS}" == "true" ]]; then
    UPDATE_PROCESS_JDWP="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32888"
  fi
fi

java ${UPDATE_PROCESS_JDWP} -jar ${CLIENT_WS_JAR} \
  -startUpdateProcess \
  --url http://127.0.0.1:8080 \
  --scheme mdsplus \
  --run-as-service \
  --slice-limit 100
