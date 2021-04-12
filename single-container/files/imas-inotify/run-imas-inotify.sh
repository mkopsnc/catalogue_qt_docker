#!/bin/bash

[ -f /home/imas/opt/etc/services-env ] && . /home/imas/opt/etc/services-env

WRAPPER_CMD=$(readlink -m $0)
WRAPPER_CMD_DIR=$(dirname ${WRAPPER_CMD})

cd ${WRAPPER_CMD_DIR}

python imas-inotify.py

