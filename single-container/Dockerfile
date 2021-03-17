FROM imas/ual

LABEL author="michal.owsiak@man.poznan.pl"
LABEL description="Docker based installation of Catalogue QT"

USER root

RUN apt-get update  -y
RUN apt-get install -y libaio1
RUN apt-get install -y libtinfo5
RUN apt-get install -y wget
RUN apt-get install -y maven
RUN apt-get install -y default-jdk
RUN apt-get install -y netcat

ENV JAVA_HOME=/usr/lib/jvm/default-java

RUN useradd --create-home --shell /bin/bash imas && \
    su - imas sh -c 'MODULEPATH=/opt/imas/etc/modulefiles module load IMAS; mkdir -p /home/imas/public/imasdb; command imasdb test'

# Installation of MySQL from binary distribution
RUN mkdir -p /opt/packages/
WORKDIR /opt/packages/

# Get the package and put the content in proper location
RUN mkdir -p /usr/local/mysql
RUN wget -q https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
RUN tar -xf mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz -C /usr/local/mysql --strip-components 1
RUN rm mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
#RUN mv mysql-8.0.20-linux-glibc2.12-x86_64/* /usr/local/mysql

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

# Startup script
RUN chmod +x /etc/init.d/catalogqt
RUN chmod +x /etc/init.d/updateprocess
RUN chmod +x /etc/init.d/mysql

# Make sure all services are started during boot time
RUN update-rc.d mysql defaults
RUN update-rc.d catalogqt defaults
RUN update-rc.d updateprocess defaults

# Copy *properties* into Docker so we can overwrite server settings
COPY files/server/*properties* /tmp/server/

# Copy config.ini for imas-inotify, we have to alter it's settings
COPY files/imas-inotify/* /tmp/imas-inotify/

# Now, we have to prepare whole structure of source code
USER imas
WORKDIR /home/imas

#This is an opt inside user imas directory (do not confuse it with /opt)
RUN mkdir -p /home/imas/opt
COPY external/catalog_qt_2.tar /home/imas/opt/catalog_qt_2.tar
WORKDIR /home/imas/opt
RUN tar xf catalog_qt_2.tar

# Build Java codes
# Prepare compilation script for Java based codes
# and run it
COPY --chown=imas scripts/compile.sh /home/imas/opt/compile.sh
RUN chmod +x /home/imas/opt/compile.sh
RUN /home/imas/opt/compile.sh

USER root

# XLST - transformation file that generates SQL queries for variables is located here:
# /home/imas/opt/catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl

RUN xsltproc /home/imas/opt/catalog_qt_2/sql/feed/imas/dumpSummaryFieldsSQL.xsl `ls -1 /opt/imas/core/IMAS/*/include/IDSDef.xml | head -1` > /tmp/variables

# We have to prepare database for Catalog QT.

RUN echo "/usr/local/mysql/bin/mysqld_safe --user=mysql &" > /tmp/config && \  
   echo "/usr/local/mysql/bin/mysqladmin -uroot -ppassword --silent --wait=30 ping || exit 1" >> /tmp/config && \  
   #  
   # We prepare structure of DB, by running base script, and its alter scripts 'a_'  
   echo "for a_sql_file in /home/imas/opt/catalog_qt_2/sql/schema/a_*" >> /tmp/config && \  
   echo "do" >> /tmp/config && \  
   echo "/usr/local/mysql/bin/mysql -uroot -ppassword < \$a_sql_file" >> /tmp/config && \  
   echo "done" >> /tmp/config && \  
   #  
   #After creating structure od DB we have to import data, and load alter scripts for modyfing data in DB 'd_'  
   echo "/usr/local/mysql/bin/mysql -uroot -ppassword itm_catalog_qt < /tmp/variables" >> /tmp/config && \  
   echo "for d_sql_file in /home/imas/opt/catalog_qt_2/sql/schema/d_*" >> /tmp/config && \  
   echo "do" >> /tmp/config && \  
   echo "/usr/local/mysql/bin/mysql -uroot -ppassword itm_catalog_qt < \$d_sql_file" >> /tmp/config && \  
   echo "done" >> /tmp/config && \  
   #
   # end of modyfing DB.
   echo "/usr/local/mysql/bin/mysqladmin shutdown -u root -ppassword --wait=30 ping || exit 1" >> /tmp/config && \  
   bash /tmp/config && \  
   rm -f /tmp/config
   
# This part of Docker file is responsible for setting up services (UpdateProcess and notify service)

USER imas

# Wrapper script is a convenient way of setting up IMAS env. variables and
# running update process
COPY --chown=imas scripts/wrapper.sh /home/imas/opt/catalog_qt_2/client/catalog-ws-client/wrapper.sh
RUN chmod +x /home/imas/opt/catalog_qt_2/client/catalog-ws-client/wrapper.sh

COPY --chown=imas scripts/catalogqt.sh /home/imas/opt/catalog_qt_2/server/catalog-ws-server/catalogqt.sh
RUN chmod +x /home/imas/opt/catalog_qt_2/server/catalog-ws-server/catalogqt.sh

# Install imas-inotify and dependencies
ARG INOTIFY_TAG
ENV INOTIFY_TAG_BASH=${INOTIFY_TAG:-master}

RUN echo "INOTIFY_TAG:      ${INOTIFY_TAG}"
RUN echo "INOTIFY_TAG_BASH: ${INOTIFY_TAG_BASH}"

RUN git clone --single-branch --branch ${INOTIFY_TAG_BASH} https://github.com/tzok/imas-inotify.git /home/imas/opt/imas-inotify

RUN if [ -e /tmp/imas-inotify/config.ini ]; then cp /tmp/imas-inotify/config.ini /home/imas/opt/imas-inotify/config.ini; fi

# Configure imas-inotify
COPY --chown=imas scripts/handler-new-pulsefile.py /home/imas/opt/imas-inotify/handler-new-pulsefile.py

USER root

# Getting token for imas-inotify
RUN java \
    -jar /home/imas/opt/catalog_qt_2/client/catalog-ws-client/target/catalogAPI.jar \
    -keyCloakServiceLogin \
    --realm-settings-file /home/imas/opt/catalog_qt_2/client/catalog-ws-client/src/main/resources/service-login.properties

# Install imas-inotify dependencies
RUN pip3 install -r /home/imas/opt/imas-inotify/requirements.txt

# Enable imas-inotify service
COPY init.d/imas-inotify /etc/init.d/imas-inotify
RUN  update-rc.d imas-inotify defaults

# Prepare entry point script
COPY scripts/run.sh /opt/run.sh
RUN chmod +x /opt/run.sh
CMD /opt/run.sh


