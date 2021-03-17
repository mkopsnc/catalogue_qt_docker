#!/bin/bash

if [ -e /home/imas/opt/catalog_qt_2/plugin/imas-feeder-plugin ]; then
 
  # common
  cd /home/imas/opt/catalog_qt_2/common/catalog-ws-common
  mvn install -DskipTests
  
  # plugin
  cd /home/imas/opt/catalog_qt_2/plugin/imas-feeder-plugin
  mkdir -p local-maven-repo
  mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
    -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` \
    -DgroupId=imas \
    -DartifactId=imas \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=jar \
    -DlocalRepositoryPath=`pwd`/local-maven-repo
  mvn install -DskipTests

  # client
  cd /home/imas/opt/catalog_qt_2/client/catalog-ws-client
 
  mvn install -DskipTests

  # server
  cd /home/imas/opt/catalog_qt_2/server/catalog-ws-server  
  if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties ./src/main/resources/application.properties; fi
  mvn compile -DskipTests

else

  # common
  cd /home/imas/opt/catalog_qt_2/common/catalog-ws-common
  mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
    -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` \
    -DgroupId=imas \
    -DartifactId=imas \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=jar \
    -DlocalRepositoryPath=`pwd`/local-maven-repo 

  mvn install -DskipTests

  # client
  cd /home/imas/opt/catalog_qt_2/client/catalog-ws-client
  mkdir -p local-maven-repo

  mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
    -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` \
    -DgroupId=imas \
    -DartifactId=imas \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=jar \
    -DlocalRepositoryPath=`pwd`/local-maven-repo

  mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
    -Dfile=/home/imas/opt/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar \
    -DgroupId=catalog-ws-common \
    -DartifactId=catalog-ws-common \
    -Dversion=1.0.0-SNAPSHOT \
    -Dpackaging=jar \
    -DlocalRepositoryPath=`pwd`/local-maven-repo

  mvn install -DskipTests

  # server
  cd /home/imas/opt/catalog_qt_2/server/catalog-ws-server
  if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties ./src/main/resources/application.properties; fi
  mvn compile -DskipTests
  
fi

