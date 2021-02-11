#!/bin/bash
while :; do
    echo 'Trying to connect to db:3306'
    curl -s -o /dev/null db:3306
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 3
done

cd /catalog_qt_2/server/catalog-ws-server/

if [ -z "$DEBUG" ]; then
    exec mvn spring-boot:run
  else
    echo "======RUNNING SERVER IN DEBUG MODE======"
    mvn install -DskipTests
    exec java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar ./target/catalog-ws-server-1.0.0-SNAPSHOT.jar
fi