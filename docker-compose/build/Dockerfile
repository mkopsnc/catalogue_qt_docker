FROM imas/ual AS ual

COPY catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl /tmp/dumpSummaryFieldsSQL.xsl
COPY catalog_qt_2/sql/feed/imas/dumpFairFieldsSQL.xsl /tmp/dumpFairFieldsSQL.xsl

RUN echo 'USE itm_catalog_qt' > /tmp/b_001_variables.sql && \
    echo 'USE itm_catalog_qt' > /tmp/b_002_variables.sql && \
    xsltproc /tmp/dumpSummaryFieldsSQL.xsl /opt/imas/core/IMAS/*/include/IDSDef.xml >> /tmp/b_001_variables.sql && \
    xsltproc /tmp/dumpFairFieldsSQL.xsl /opt/imas/core/IMAS/*/include/IDSDef.xml >> /tmp/b_002_variables.sql


################################################################################

FROM mariadb AS db

COPY catalog_qt_2/sql/schema/*.sql /docker-entrypoint-initdb.d/
COPY --from=ual /tmp/b_001_variables.sql /docker-entrypoint-initdb.d/
COPY --from=ual /tmp/b_002_variables.sql /docker-entrypoint-initdb.d/

RUN sed -i '1 i USE itm_catalog_qt' /docker-entrypoint-initdb.d/d_*.sql

################################################################################

FROM imas/ual AS base

COPY catalog_qt_2 /catalog_qt_2

COPY files/compile-scripts/* /tmp/compile-scripts/
RUN chmod +x /tmp/compile-scripts/compile-plugins.sh
RUN chmod +x /tmp/compile-scripts/compile-common.sh
RUN chmod +x /tmp/compile-scripts/compile-server.sh
RUN chmod +x /tmp/compile-scripts/compile-client.sh

ENV JAVA_HOME=/usr/lib/jvm/default-java

RUN apt-get update && \
    apt-get install -y \
        default-jdk \
        maven \
        wait-for-it && \
    rm -rf /var/lib/apt/lists/*

RUN /tmp/compile-scripts/compile-common.sh /catalog_qt_2
RUN /tmp/compile-scripts/compile-plugins.sh /catalog_qt_2

RUN useradd --create-home --shell /bin/bash imas && \
    su - imas sh -c 'MODULEPATH=/opt/imas/etc/modulefiles module load IMAS; mkdir -p /home/imas/public/imasdb; command imasdb test'

################################################################################

FROM base AS server

RUN /tmp/compile-scripts/compile-server.sh /catalog_qt_2

RUN mkdir /home/imas/server-properties

COPY files/server.sh /server.sh
CMD ["/server.sh"]
EXPOSE 8080
EXPOSE 8443

################################################################################

FROM base AS client

RUN /tmp/compile-scripts/compile-client.sh /catalog_qt_2

################################################################################

FROM client AS updateprocess

COPY files/updateprocess.sh /updateprocess.sh
CMD ["/updateprocess.sh"]

################################################################################

FROM client AS watchdog

COPY imas-watchdog /imas-watchdog

RUN pip3 install -r imas-watchdog/requirements.txt

COPY files/watchdog.sh /watchdog.sh

CMD ["/watchdog.sh"]

