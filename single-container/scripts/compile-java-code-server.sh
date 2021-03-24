#!/bin/bash

if [ -e /home/imas/opt/catalog_qt_2/plugin/imas-feeder-plugin ]; then
 
  # server
  cd /home/imas/opt/catalog_qt_2/server/catalog-ws-server  
  if [ -e /tmp/server/application.properties.patch ]; then patch ./src/main/resources/application.properties /tmp/server/application.properties.patch
  if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties ./src/main/resources/application.properties; fi
  if [ -e /tmp/server/url.properties ]; then cp /tmp/server/url.properties ./src/main/resources/url.properties; fi
  mvn compile -DskipTests
  mvn package -DskipTests

else

  # server
  cd /home/imas/opt/catalog_qt_2/server/catalog-ws-server
  if [ -e /tmp/server/application.properties.patch ]; then patch ./src/main/resources/application.properties /tmp/server/application.properties.patch
  if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties ./src/main/resources/application.properties; fi
  if [ -e /tmp/server/url.properties ]; then cp /tmp/server/url.properties ./src/main/resources/url.properties; fi

  mkdir -p local-maven-repo

  mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
    -Dfile=/home/imas/opt/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar \
    -DgroupId=catalog-ws-common \
    -DartifactId=catalog-ws-common \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=jar \
    -DlocalRepositoryPath=`pwd`/local-maven-repo

  mvn compile -DskipTests
  mvn package -DskipTests
  
fi

