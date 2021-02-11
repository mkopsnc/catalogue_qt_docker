#!/bin/bash

if [ -e /home/imas/opt/catalog_qt_2/plugin/imas-feeder-plugin ]; then
  mkdir -p /home/imas/opt/catalog_qt_2/plugin/imas-feeder-plugin/local-maven-repo
  cd /home/imas/opt/catalog_qt_2/plugin/imas-feeder-plugin/
  mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file -Dfile=`ls -1 /opt/imas/core/IMAS/*/jar/imas.jar | head -1` -DgroupId=imas -DartifactId=imas -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar -DlocalRepositoryPath=`pwd`/local-maven-repo
  mvn install -DskipTests
fi

