#!/bin/bash

[ -f /home/imas/opt/etc/services-env ] && . /home/imas/opt/etc/services-env

CATALOG_QT_CMD=$(readlink -m $0)
CATALOG_QT_CMD_DIR=$(dirname ${CATALOG_QT_CMD})

DD_VER=`ls -1 /opt/imas/core/IMAS | head -1 | cut -f1 -d'-'`
AL_VER=`ls -1 /opt/imas/core/IMAS | head -1 | cut -f2 -d'-'`

export IMAS_HOME=/opt/imas
export IMAS_CORE=/opt/imas/core
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}/lib:/usr/local/mdsplus/lib:/opt/uda/lib
export CLASSPATH=${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}/jar/imas.jar:/usr/share/java/saxon9he.jar
export IMAS_PREFIX=${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}
export IMAS_VERSION=${DD_VER}
export ids_path=${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}/models/mdsplus
export UAL_VERSION=${AL_VER}

cd ${CATALOG_QT_CMD_DIR}

loop=1
tries=10

while [ $loop == 1 ]; do

  echo 'Trying to connect to localhost:3396'
  nc -z -w1 localhost 3306
  retVal=$?

  if [ $retVal -ne 0 ]; then
    sleep 10
    echo "Starting Spring Boot - failed to connect to DB. Trying again in 10 seconds."
    tries=$((tries-1))
    if [ $tries == 0 ]; then
      echo "Starting Spring Boot - failed to connect to DB. Quiting after 10 retries."
      exit 1
    fi
  else
    loop=0
  fi
done

DEBUG_SPRING_BOOT_JDWP=""

if [ ! -z "$DEBUG_SPRING_BOOT" ]; then
  if [[ "${DEBUG_SPRING_BOOT}" == "true" ]]; then
    DEBUG_SPRING_BOOT_JDWP="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32889"
  fi
fi

JAR_FILE=$(ls -1 ./target/catalog-ws-server-*-SNAPSHOT.jar)

java ${DEBUG_SPRING_BOOT_JDWP} -jar ${JAR_FILE}
