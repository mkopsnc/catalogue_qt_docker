FROM imas/ual AS ual

COPY catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl /tmp/dumpSummaryFieldsSQL.xsl

RUN cp /opt/imas/core/IMAS/*/jar/imas.jar /tmp/imas.jar && \
    echo 'USE itm_catalog_qt' > /tmp/20-variables.sql && \
    xsltproc /tmp/dumpSummaryFieldsSQL.xsl /opt/imas/core/IMAS/*/include/IDSDef.xml >> /tmp/20-variables.sql

################################################################################

FROM maven AS catalog_qt_base

COPY catalog_qt_2 /catalog_qt_2
COPY --from=ual /tmp/imas.jar /tmp/imas.jar

RUN sh -c 'cd /catalog_qt_2/common/catalog-ws-common; mvn package' && \
    mvn install:install-file -Dfile=/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar -DgroupId=catalog-ws-common -DartifactId=catalog-ws-common -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar && \
    mvn install:install-file -Dfile=/tmp/imas.jar -DgroupId=imas -DartifactId=imas -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar && \
    sh -c 'cd /catalog_qt_2/client/catalog-ws-client; mvn install -DskipTests'

################################################################################

FROM catalog_qt_base AS updateprocess

WORKDIR /catalog_qt_2/client/catalog-ws-client

CMD ./wrapper.sh

################################################################################

FROM catalog_qt_base AS catalog_qt_server

WORKDIR /catalog_qt_2/server/catalog-ws-server/

RUN mvn compile -DskipTests

CMD mvn spring-boot:run

################################################################################

FROM mysql AS db

COPY catalog_qt_2/sql/schema/catalog_qt_db.sql /docker-entrypoint-initdb.d/10-schema.sql
COPY --from=ual /tmp/20-variables.sql /docker-entrypoint-initdb.d/20-variables.sql
