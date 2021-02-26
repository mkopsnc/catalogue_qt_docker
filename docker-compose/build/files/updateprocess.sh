#!/bin/bash
cd /catalog_qt_2/client/catalog-ws-client/

wait-for-it server:8080 --timeout=0

exec java -jar target/catalogAPI.jar \
    -startUpdateProcess \
    --url http://server:8080 \
    --scheme mdsplus \
    --slice-limit 100
