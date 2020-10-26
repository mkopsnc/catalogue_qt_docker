#!/bin/bash
while :; do
    echo 'Trying to connect to server:8080...'
    curl -s -o /dev/null server:8080
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 3
done

cd imas-inotify
exec ./imas-inotify.py --config /config.ini --verbose
