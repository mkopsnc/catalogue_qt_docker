#!/bin/bash
cd /home/imas/catalog_qt_2/server/catalog-ws-server/

wait-for-it db:3306 --timeout=0

if [ -z "$DEBUG" ]; then
    exec java \
        -jar ./target/catalog-ws-server-*-SNAPSHOT.jar
else
    echo "======RUNNING SERVER IN DEBUG MODE======"
    exec java \
        -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 \
        -jar ./target/catalog-ws-server-*-SNAPSHOT.jar
fi
