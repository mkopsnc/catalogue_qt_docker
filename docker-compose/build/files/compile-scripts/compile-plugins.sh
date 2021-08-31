#!/bin/bash

set -e

CATALOG_QT_HOME=$1

# plugin - this script is required for backward compatibility

if [ -e ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin ]; then
  
  RESULT=$(find ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin/target -name "imas-feeder-plugin-*" | wc -l)

  if [[ $RESULT -eq 0 ]]; then 

    cd ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin
    mkdir -p local-maven-repo
    mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
      -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` \
      -DgroupId=imas \
      -DartifactId=imas \
      -Dversion=1.0.0-SNAPSHOT \
      -Dpackaging=jar \
      -DlocalRepositoryPath=`pwd`/local-maven-repo
    mvn install -DskipTests

  fi

fi

if [ -e ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin-reader ]; then

  RESULT=$(find ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin-uri-parser/target -name "imas-feeder-plugin-uri-parser*" | wc -l)
  if [[ $RESULT -eq 0 ]]; then 

    cd ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin-uri-parser
    mvn install -DskipTests

  fi

  RESULT=$(find ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin-reader/target -name "imas-feeder-plugin-reader*" | wc -l)
  if [[ $RESULT -eq 0 ]]; then 

    cd ${CATALOG_QT_HOME}/plugin/imas-feeder-plugin-reader
    mkdir -p local-maven-repo
    mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file \
      -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` \
      -DgroupId=imas \
      -DartifactId=imas \
      -Dversion=1.0.0-SNAPSHOT \
      -Dpackaging=jar \
      -DlocalRepositoryPath=`pwd`/local-maven-repo
    mvn install -DskipTests

  fi

fi

