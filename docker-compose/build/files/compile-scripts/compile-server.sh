#!/bin/bash

CATALOG_QT_HOME=$1

# server - this script is required for backward compatibility

RESULT=$(find ${CATALOG_QT_HOME}/server/catalog-ws-server/target -name "catalog-ws-server-*" | wc -l)
  
if [[ $RESULT -eq 0 ]]; then

  if [ -e ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin ]; then
 
    cd ${CATALOG_QT_HOME}/server/catalog-ws-server  
    mvn compile -DskipTests
    mvn package -DskipTests

  else

    # server
    cd ${CATALOG_QT_HOME}/server/catalog-ws-server

    mkdir -p local-maven-repo

    mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
      -Dfile=${CATALOG_QT_HOME}/common/catalog-ws-common/target/catalog-ws-common.jar \
      -DgroupId=catalog-ws-common \
      -DartifactId=catalog-ws-common \
      -Dversion=1.0.0-SNAPSHOT \
      -Dpackaging=jar \
      -DlocalRepositoryPath=`pwd`/local-maven-repo

    mvn compile -DskipTests
    mvn package -DskipTests

  fi
  
fi

