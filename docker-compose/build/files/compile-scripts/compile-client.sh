#!/bin/bash

CATALOG_QT_HOME=$1

# client - this script is required for backward compatibility

RESULT=$(find ${CATALOG_QT_HOME}/client/catalog-ws-client/target -name "catalog-ws-client-*" | wc -l)
  
if [[ $RESULT -eq 0 ]]; then

  if [ -e ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin ]; then
 
    cd ${CATALOG_QT_HOME}/client/catalog-ws-client
    mvn install -DskipTests

  else

    cd ${CATALOG_QT_HOME}/client/catalog-ws-client
    mkdir -p local-maven-repo

    mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
      -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` \
      -DgroupId=imas \
      -DartifactId=imas \
      -Dversion=1.0.0-SNAPSHOT \
      -Dpackaging=jar \
      -DlocalRepositoryPath=`pwd`/local-maven-repo

    mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
      -Dfile=${CATALOG_QT_HOME}/common/catalog-ws-common/target/catalog-ws-common.jar \
      -DgroupId=catalog-ws-common \
      -DartifactId=catalog-ws-common \
      -Dversion=1.0.0-SNAPSHOT \
      -Dpackaging=jar \
      -DlocalRepositoryPath=`pwd`/local-maven-repo

    mvn install -DskipTests

  fi

fi

