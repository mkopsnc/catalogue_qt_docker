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

RUN apt-get update -y && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists

COPY catalog_qt_2 /catalog_qt_2

RUN sh -c 'cd /catalog_qt_2/common/catalog-ws-common; mvn install -DskipTests' && \
    mvn install:install-file -Dfile=/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar -DgroupId=catalog-ws-common -DartifactId=catalog-ws-common -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar && \
    cp /opt/imas/core/IMAS/*/jar/imas.jar /tmp/imas.jar && \
    mvn install:install-file -Dfile=/tmp/imas.jar -DgroupId=imas -DartifactId=imas -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar

RUN useradd --create-home --shell /bin/bash imas && \
    su - imas sh -c 'MODULEPATH=/opt/imas/etc/modulefiles module load IMAS; mkdir -p /home/imas/public/imasdb; command imasdb test'

################################################################################

FROM base AS server

COPY files/server.sh /server.sh

RUN sed -i 's/localhost/db/g' /catalog_qt_2/server/catalog-ws-server/src/main/resources/application.properties && \
    sh -c 'cd /catalog_qt_2/server/catalog-ws-server; mvn package -DskipTests'

CMD /server.sh

################################################################################

FROM base AS client

RUN sh -c 'cd /catalog_qt_2/client/catalog-ws-client; mvn package -DskipTests'

################################################################################

FROM client AS updateprocess

COPY files/updateprocess.sh /updateprocess.sh

CMD /updateprocess.sh

################################################################################

FROM client AS inotify

COPY files/config.ini /config.ini
COPY files/inotify.sh /inotify.sh

RUN git clone -b develop https://github.com/tzok/imas-inotify.git && \
    pip3 install -r imas-inotify/requirements.txt

CMD /inotify.sh

################################################################################

FROM python AS dashboard

COPY demonstrator-dashboard /demonstrator-dashboard
COPY files/dashboard-secrets.json /demonstrator-dashboard/dashboard/settings/secrets.json
COPY files/dashboard.sh /dashboard.sh

RUN pip install -r /demonstrator-dashboard/requirements.txt && \
    sed -i '/API_ROOT =/ a API_ROOT = "http://server:8080/"' /demonstrator-dashboard/db_api/services.py

CMD /dashboard.sh
