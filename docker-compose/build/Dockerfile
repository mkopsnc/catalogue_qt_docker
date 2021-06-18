FROM imas/ual AS ual

COPY catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl /tmp/dumpSummaryFieldsSQL.xsl

RUN echo 'USE itm_catalog_qt' > /tmp/b_001_variables.sql && \
    xsltproc /tmp/dumpSummaryFieldsSQL.xsl /opt/imas/core/IMAS/*/include/IDSDef.xml >> /tmp/b_001_variables.sql

################################################################################

FROM mariadb AS db

COPY catalog_qt_2/sql/schema/*.sql /docker-entrypoint-initdb.d/
COPY --from=ual /tmp/b_001_variables.sql /docker-entrypoint-initdb.d/

RUN sed -i '1 i USE itm_catalog_qt' /docker-entrypoint-initdb.d/d_*.sql

################################################################################

FROM imas/ual AS base

RUN useradd --create-home --shell /bin/bash --uid 1000 --gid 0 imas && \
    su - imas sh -c 'MODULEPATH=/opt/imas/etc/modulefiles module load IMAS; mkdir -p /home/imas/public/imasdb; command imasdb test'

COPY --chown=imas:root catalog_qt_2 /home/imas/catalog_qt_2
COPY --chown=imas:root files/compile-scripts/* /tmp/compile-scripts/

RUN chown -R 1000:0 /home/imas && \
    chmod -R g+w /home/imas/ && \
    chown -R 1000:0 /etc && \
    chmod -R g+w /etc

COPY files/uid_entrypoint.sh /uid_entrypoint.sh
RUN chmod g=u /etc/passwd && chmod 775 /uid_entrypoint.sh

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

USER 1000
WORKDIR /home/imas
ENV HOME=/home/imas
ENV USER=imas

RUN /tmp/compile-scripts/compile-common.sh /home/imas/catalog_qt_2
RUN /tmp/compile-scripts/compile-plugins.sh /home/imas/catalog_qt_2

ENTRYPOINT [ "/uid_entrypoint.sh", "/docker-entrypoint.sh" ]

################################################################################

FROM base AS server

COPY --chown=imas:root files/server/*properties* /tmp/server/

RUN patch -p0 < /tmp/server/application.properties.patch

RUN if [ -e /tmp/server/application.properties ]; then cp /tmp/server/application.properties catalog_qt_2/server/catalog-ws-server/src/main/resources/; fi
RUN if [ -e /tmp/server/url.properties ]; then cp /tmp/server/url.properties catalog_qt_2/server/catalog-ws-server/src/main/resources/; fi

RUN /tmp/compile-scripts/compile-server.sh /home/imas/catalog_qt_2

COPY --chown=imas:root files/server.sh /home/imas/server.sh
CMD ["/home/imas/server.sh"]
EXPOSE 8080
EXPOSE 8443

################################################################################

FROM base AS client

RUN /tmp/compile-scripts/compile-client.sh /home/imas/catalog_qt_2

################################################################################

FROM client AS updateprocess

COPY files/updateprocess.sh /home/imas/updateprocess.sh

CMD ["/home/imas/updateprocess.sh"]

################################################################################

FROM client AS watchdog

COPY --chown=imas:root imas-watchdog /home/imas/imas-watchdog

RUN pip3 install --user -r imas-watchdog/requirements.txt
RUN chmod -R g=u /home/imas/.local

COPY --chown=imas:root files/watchdog.sh /home/imas/watchdog.sh

CMD ["/home/imas/watchdog.sh"]

