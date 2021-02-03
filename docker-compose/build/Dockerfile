FROM imas/ual AS ual

COPY catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl /tmp/dumpSummaryFieldsSQL.xsl

RUN echo 'USE itm_catalog_qt' > /tmp/20-variables.sql && \
    xsltproc /tmp/dumpSummaryFieldsSQL.xsl /opt/imas/core/IMAS/*/include/IDSDef.xml >> /tmp/20-variables.sql

################################################################################

FROM mysql AS db

COPY catalog_qt_2/sql/schema/catalog_qt_db.sql /docker-entrypoint-initdb.d/10-schema.sql
COPY --from=ual /tmp/20-variables.sql /docker-entrypoint-initdb.d/20-variables.sql

################################################################################

FROM imas/ual AS base

RUN apt-get update -y
RUN apt-get install -y default-jdk

ENV JAVA_HOME=/usr/lib/jvm/default-java

RUN apt-get install -y maven && \
    rm -rf /var/lib/apt/lists

COPY catalog_qt_2 /catalog_qt_2

RUN mvn --file /catalog_qt_2/common/catalog-ws-common/pom.xml install -DskipTests && \
    mvn install:install-file -Dfile=/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar -DgroupId=catalog-ws-common -DartifactId=catalog-ws-common -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar && \
    cp /opt/imas/core/IMAS/*/jar/imas.jar /tmp/imas.jar && \
    mvn install:install-file -Dfile=/tmp/imas.jar -DgroupId=imas -DartifactId=imas -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar

RUN useradd --create-home --shell /bin/bash imas && \
    su - imas sh -c 'MODULEPATH=/opt/imas/etc/modulefiles module load IMAS; mkdir -p /home/imas/public/imasdb; command imasdb test'

################################################################################

FROM base AS server

COPY files/server.sh /server.sh
RUN  mkdir /tmp/server
COPY files/server/application.properties.patch /tmp/server/application.properties.patch
COPY files/server/application.properties.overwrite /tmp/server/application.properties.overwrite
COPY files/server/url.properties.overwrite /tmp/server/url.properties.overwrite

RUN patch -p0 < /tmp/server/application.properties.patch
RUN if [ `head -1 /tmp/server/application.properties.overwrite | grep '# Intentionally left empty' | wc -l` -eq 0 ]; then cp /tmp/server/application.properties.overwrite /catalog_qt_2/server/catalog-ws-server/src/main/resources/application.properties; fi
RUN if [ `head -1 /tmp/server/url.properties.overwrite | grep '# Intentionally left empty' | wc -l` -eq 0 ]; then cp /tmp/server/url.properties.overwrite /catalog_qt_2/server/catalog-ws-server/src/main/resources/url.properties; fi
RUN mvn --file /catalog_qt_2/server/catalog-ws-server/pom.xml package -DskipTests

CMD ["/server.sh"]

################################################################################

FROM base AS client

RUN mvn --file /catalog_qt_2/client/catalog-ws-client/pom.xml package -DskipTests

################################################################################

FROM client AS updateprocess

COPY files/updateprocess.sh /updateprocess.sh

CMD ["/updateprocess.sh"]

################################################################################

FROM client AS inotify

COPY imas-inotify /imas-inotify
COPY files/inotify.sh /inotify.sh

RUN pip3 install -r imas-inotify/requirements.txt

CMD ["/inotify.sh"]

################################################################################

FROM python AS dashboard

COPY demonstrator-dashboard /demonstrator-dashboard
COPY files/dashboard.sh /dashboard.sh
COPY files/demonstrator-dashboard.patch /tmp/demonstrator-dashboard.patch

RUN patch -p0 < /tmp/demonstrator-dashboard.patch && \
    pip install -r /demonstrator-dashboard/requirements.txt

CMD ["/dashboard.sh"]
