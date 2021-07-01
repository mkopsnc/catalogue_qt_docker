#!/bin/bash
cd /catalog_qt_2/server/catalog-ws-server/

wait-for-it db:3306 --timeout=0

DEBUG_SPRING_BOOT_JDWP=""
APPLICATION_PROPERTIES=""

if [ ! -z "$DEBUG_SPRING_BOOT" ]; then
  if [[ "${DEBUG_SPRING_BOOT}" == "true" ]]; then
    DEBUG_SPRING_BOOT_JDWP="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32889"
  fi
fi

if [ -e /home/imas/server-properties/application.properties ]; then
#  APPLICATION_PROPERTIES="--spring.config.name=application --spring.config.location=file:///home/imas/server-properties"
  mkdir -p config
  cp /home/imas/server-properties/application.properties ./config
fi

JAR_FILE=$(ls -1 ./target/catalog-ws-server-*-SNAPSHOT.jar)

exec java ${DEBUG_SPRING_BOOT_JDWP} -jar ${JAR_FILE} ${APPLICATION_PROPERTIES}

ls -la //home/imas/server-properties
cat /home/imas/server-properties/application.properties
