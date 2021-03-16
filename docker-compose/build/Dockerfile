FROM imas/ual AS ual

COPY catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl /tmp/dumpSummaryFieldsSQL.xsl

RUN echo 'USE itm_catalog_qt' > /tmp/20-variables.sql && \
    xsltproc /tmp/dumpSummaryFieldsSQL.xsl /opt/imas/core/IMAS/*/include/IDSDef.xml >> /tmp/20-variables.sql

################################################################################

FROM mariadb AS db

COPY catalog_qt_2/sql/schema/a_001_catalog_qt_db.sql /docker-entrypoint-initdb.d/10-schema.sql
COPY --from=ual /tmp/20-variables.sql /docker-entrypoint-initdb.d/20-variables.sql
COPY catalog_qt_2/sql/schema/d_001_update_variables.sql /docker-entrypoint-initdb.d/30-alter_update_variables.sql

################################################################################

FROM imas/ual AS base

COPY catalog_qt_2 /catalog_qt_2

ENV JAVA_HOME=/usr/lib/jvm/default-java

RUN apt-get update && \
    apt-get install -y \
        default-jdk \
        maven \
        wait-for-it && \
    rm -rf /var/lib/apt/lists/*

RUN mvn --file /catalog_qt_2/common/catalog-ws-common/pom.xml install -DskipTests && \
    mvn install:install-file -Dfile=/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar -DgroupId=catalog-ws-common -DartifactId=catalog-ws-common -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar && \
    cp /opt/imas/core/IMAS/*/jar/imas.jar /tmp/imas.jar && \
    mvn install:install-file -Dfile=/tmp/imas.jar -DgroupId=imas -DartifactId=imas -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar && \
    rm /tmp/imas.jar

RUN useradd --create-home --shell /bin/bash imas && \
    su - imas sh -c 'MODULEPATH=/opt/imas/etc/modulefiles module load IMAS; mkdir -p /home/imas/public/imasdb; command imasdb test'

################################################################################

FROM base AS server

COPY files/server-override/* /tmp/server-override/

RUN if [ -e /tmp/server-override/application.properties ]; then cp /tmp/server-override/application.properties /catalog_qt_2/server/catalog-ws-server/src/main/resources/; fi && \
    if [ -e /tmp/server-override/url.properties ]; then cp /tmp/server-override/url.properties /catalog_qt_2/server/catalog-ws-server/src/main/resources/; fi && \
    mvn --file /catalog_qt_2/server/catalog-ws-server/pom.xml package -DskipTests

COPY files/server.sh /server.sh

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

RUN pip3 install -r imas-inotify/requirements.txt

COPY files/inotify.sh /inotify.sh

CMD ["/inotify.sh"]

################################################################################

FROM python AS dashboard

COPY demonstrator-dashboard /demonstrator-dashboard
COPY files/demonstrator-dashboard-override/* /tmp/demonstrator-dashboard-override/

RUN apt-get update && \
    apt-get install -y \
        wait-for-it && \
    rm -rf /var/lib/apt/lists/*

RUN if [ -e /tmp/demonstrator-dashboard-override/services_constants.py ]; then cp /tmp/demonstrator-dashboard-override/services_constants.py /demonstrator-dashboard/db_api/utils/; fi && \
    pip install -r /demonstrator-dashboard/requirements.txt

COPY files/dashboard.sh /dashboard.sh

CMD ["/dashboard.sh"]
