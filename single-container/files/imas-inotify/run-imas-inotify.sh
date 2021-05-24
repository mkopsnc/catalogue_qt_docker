#!/bin/bash

[ -f /home/imas/opt/etc/services-env ] && . /home/imas/opt/etc/services-env

WRAPPER_CMD=$(readlink -m $0)
WRAPPER_CMD_DIR=$(dirname ${WRAPPER_CMD})

DD_VER=`ls -1 /opt/imas/core/IMAS | head -1 | cut -f1 -d'-'`
AL_VER=`ls -1 /opt/imas/core/IMAS | head -1 | cut -f2 -d'-'`

export IMAS_HOME=/opt/imas
export IMAS_CORE=/opt/imas/core
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}/lib:/usr/local/mdsplus/lib:/opt/uda/lib
export CLASSPATH=${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}/jar/imas.jar:/usr/share/java/saxon9he.jar
export IMAS_PREFIX=${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}
export IMAS_VERSION=${DD_VER}
export ids_path=${IMAS_CORE}/IMAS/${DD_VER}-${AL_VER}/models/mdsplus
export UAL_VERSION=${AL_VER}

cd ${WRAPPER_CMD_DIR}

python imas-inotify.py

