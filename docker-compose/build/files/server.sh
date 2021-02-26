#!/bin/bash
cd /catalog_qt_2/server/catalog-ws-server/

wait-for-it db:3306 --timeout=0

if [ -z "$DEBUG" ]; then
    exec mvn spring-boot:run
else
    # exec mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
    # Doesn't work. It does not propagate debug arguments to executable.
    # lsof -i -P -N | grep listen doens't show any listening process on port 5005

    echo "======RUNNING SERVER IN DEBUG MODE======"
    exec java \
        -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 \
        -jar ./target/catalog-ws-server-1.0.0-SNAPSHOT.jar
fi
