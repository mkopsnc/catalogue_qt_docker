#!/bin/bash

CATALOG_QT_CMD=$(readlink -m $0)
CATALOG_QT_CMD_DIR=$(dirname ${CATALOG_QT_CMD})

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

java ${DEBUG_SPRING_BOOT} -jar ${JAR_FILE}
