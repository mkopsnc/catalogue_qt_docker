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
exec mvn spring-boot:run
