#!/bin/bash
cd /catalog_qt_2/server/catalog-ws-server/

wait-for-it db:3306 --timeout=0

DEBUG_SPRING_BOOT_JDWP=""

if [ ! -z "$DEBUG_SPRING_BOOT" ]; then
  if [[ "${DEBUG_SPRING_BOOT}" == "true" ]]; then
    DEBUG_SPRING_BOOT_JDWP="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32889"
  fi
fi

if [ -e /home/imas/server-properties/application.properties ]; then
# `  sed -i '/spring.datasource.url/ s/localhost/db/g' /home/imas/server-properties/application.properties`
  export SPRING_CONFIG_LOCATION=file:///home/imas/server-properties/application.properties 
fi

JAR_FILE=$(ls -1 ./target/catalog-ws-server-*-SNAPSHOT.jar)

export LOG4J_FORMAT_MSG_NO_LOOKUPS = true
exec java ${DEBUG_SPRING_BOOT_JDWP} -jar ${JAR_FILE}
