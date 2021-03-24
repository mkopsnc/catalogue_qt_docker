#!/bin/bash

CATALOG_QT_HOME=$1

# server - this script is required for backward compatibility

RESULT=$(find ${CATALOG_QT_HOME}/server/catalog-ws-server/target -name "catalog-ws-server-*" | wc -l)
  
if [[ $RESULT -eq 0 ]]; then

  if [ -e ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin ]; then
 
    cd ${CATALOG_QT_HOME}/server/catalog-ws-server
    if [ -e /tmp/server/application.properties.patch ]; then patch ./src/main/resources/application.properties /tmp/server/application.properties.patch; fi
    if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties ./src/main/resources/application.properties; fi
    if [ -e /tmp/server/url.properties ]; then cp /tmp/server/url.properties ./src/main/resources/url.properties; fi
    mvn compile -DskipTests
    mvn package -DskipTests

  else

    # server
    cd ${CATALOG_QT_HOME}/server/catalog-ws-server
    if [ -e /tmp/server/application.properties.patch ]; then patch ./src/main/resources/application.properties /tmp/server/application.properties.patch; fi
    if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties ./src/main/resources/application.properties; fi
    if [ -e /tmp/server/url.properties ]; then cp /tmp/server/url.properties ./src/main/resources/url.properties; fi

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

