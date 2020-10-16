#!/bin/bash
while :; do
    echo 'Trying to connect to server:8080...'
    curl -s -o /dev/null server:8080
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 3
done

cd /catalog_qt_2/client/catalog-ws-client/
exec java -jar target/catalogAPI.jar \
    -startUpdateProcess \
    --url http://server:8080 \
    --scheme mdsplus \
    --slice-limit 100
