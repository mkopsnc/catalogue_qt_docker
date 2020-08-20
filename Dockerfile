FROM imas/fc2k

LABEL author="michal.owsiak@man.poznan.pl"
LABEL description="Docker based installation of Catalogue QT"

USER root

RUN apt-get install -y libaio1
RUN apt-get install -y wget
RUN apt-get install -y maven

# Installation of MySQL from binary distribution
RUN mkdir -p /opt/packages/
WORKDIR /opt/packages/

# Get the package and put the content in proper location
RUN wget -q https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
RUN tar -xf mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
RUN mkdir -p /usr/local/mysql
RUN mv mysql-8.0.20-linux-glibc2.12-x86_64/* /usr/local/mysql

# MySQL will be run as user mysql
RUN groupadd mysql
RUN useradd -r -g mysql -s /bin/false mysql

# We have to prepare structure of the mysql directory
WORKDIR /usr/local/mysql
RUN mkdir mysql-files
RUN chown mysql:mysql mysql-files
RUN chmod 750 mysql-files
RUN bin/mysqld --initialize-insecure  --user=mysql
RUN bin/mysql_ssl_rsa_setup
RUN echo "bin/mysqld_safe --user=mysql &" > /tmp/config && \
    echo "bin/mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
    echo "bin/mysql -e 'ALTER USER \"root\"@\"localhost\" IDENTIFIED BY \"password\";'" >> /tmp/config && \
    echo "bin/mysqladmin shutdown -u root -ppassword --wait=30 ping || exit 1" >> /tmp/config && \
    bash /tmp/config && \
    rm -f /tmp/config

# We can use init.d scripts to simplify startup procedure
ADD init.d/catalogqt /etc/init.d/catalogqt
ADD init.d/updateprocess /etc/init.d/updateprocess
RUN cp support-files/mysql.server /etc/init.d/mysql

RUN chmod +x /etc/init.d/catalogqt
RUN chmod +x /etc/init.d/updateprocess
RUN chmod +x /etc/init.d/mysql

# Make sure all services are started during boot time
RUN update-rc.d mysql defaults
RUN update-rc.d catalogqt defaults
RUN update-rc.d updateprocess defaults

# Startup script
COPY scripts/run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

# Now, we have to prepare whole structure of source code
USER imas
WORKDIR /home/imas

#This is an opt inside user imas directory (do not confuse it with /opt)
RUN mkdir -p /home/imas/opt
COPY external/catalog_qt_2.tar /home/imas/opt/catalog_qt_2.tar
WORKDIR /home/imas/opt
RUN tar xf catalog_qt_2.tar

# We have to build commons project so we can use it inside server and client parts
WORKDIR /home/imas/opt/catalog_qt_2/common/catalog-ws-common
RUN mvn package

# We can build JAR file for client application
WORKDIR /home/imas/opt/catalog_qt_2/client/catalog-ws-client

# Local repo will contain two JAR files: imas and common
RUN mkdir -p /home/imas/opt/catalog_qt_2/client/catalog-ws-client/local-maven-repo
RUN mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file -Dfile=/home/imas/imas/core/IMAS/3.28.1-4.8.1/jar/imas.jar -DgroupId=imas -DartifactId=imas -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar -DlocalRepositoryPath=`pwd`/local-maven-repo
RUN mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file -Dfile=/home/imas/opt/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar -DgroupId=catalog-ws-common -DartifactId=catalog-ws-common -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar -DlocalRepositoryPath=`pwd`/local-maven-repo

# Finally, we can build client
RUN mvn install -DskipTests

# The same goes for server. We have to make sure that common is loaded inside server's local directory
WORKDIR /home/imas/opt/catalog_qt_2/server/catalog-ws-server
RUN mkdir -p /home/imas/opt/catalog_qt_2/server/catalog-ws-server/local-maven-repo
RUN mvn org.apache.maven.plugins:maven-install-plugin:3.0.0-M1:install-file -Dfile=/home/imas/opt/catalog_qt_2/common/catalog-ws-common/target/catalog-ws-common.jar -DgroupId=catalog-ws-common -DartifactId=catalog-ws-common -Dversion=1.0.0-SNAPSHOT -Dpackaging=jar -DlocalRepositoryPath=`pwd`/local-maven-repo
RUN mvn compile -DskipTests

USER root

# XLST - transformation file that generates SQL queries for variables is located here:
# /home/imas/opt/catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl

RUN xsltproc /home/imas/opt/catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl $IMAS_PREFIX/include/IDSDef.xml > /tmp/variables

# We have to prepare database for Catalog QT.
# Schema is located here: /home/imas/opt/catalog_qt_2/sql/schema/catalog_qt_db.sql
RUN echo "/usr/local/mysql/bin/mysqld_safe --user=mysql &" > /tmp/config && \
    echo "/usr/local/mysql/bin/mysqladmin -uroot -ppassword --silent --wait=30 ping || exit 1" >> /tmp/config && \
    echo "/usr/local/mysql/bin/mysql -uroot -ppassword < /home/imas/opt/catalog_qt_2/sql/schema/catalog_qt_db.sql" >> /tmp/config && \
    echo "/usr/local/mysql/bin/mysql -uroot -ppassword itm_catalog_qt < /tmp/variables" >> /tmp/config && \
    echo "/usr/local/mysql/bin/mysqladmin shutdown -u root -ppassword --wait=30 ping || exit 1" >> /tmp/config && \
    bash /tmp/config && \
    rm -f /tmp/config

# This part of Docker file is responsible for setting up services (UpdateProcess and notify service)

USER imas

# Wrapper script is a convenient way of setting up IMAS env. variables and
# running update process
COPY --chown=imas scripts/wrapper.sh /home/imas/opt/catalog_qt_2/client/catalog-ws-client/wrapper.sh
RUN chmod +x /home/imas/opt/catalog_qt_2/client/catalog-ws-client/wrapper.sh

CMD /opt/run.sh


# Install imas-inotify and dependencies
RUN git clone https://github.com/tzok/imas-inotify.git /home/imas/opt/imas-inotify \
    && sudo pip3 install -r /home/imas/opt/imas-inotify/requirements.txt

# Enable imas-inotify service
COPY init.d/imas-inotify /etc/init.d/imas-inotify
RUN sudo update-rc.d imas-inotify defaults

# Configure imas-inotify
COPY scripts/handler-new-pulsefile.py /home/imas/opt/imas-inotify/handler-new-pulsefile.py
