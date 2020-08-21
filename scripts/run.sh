#!/bin/bash

cd $HOME

cat << EOF
      ****************************************************
         https://github.com/mkopsnc/catalogue_qt_docker
      ****************************************************
        This Docker container provides functionality
        of IMAS based Catalog QT service.
        ------------------------------------------------
        
        Once started, you can visit:

        http://localhost:8080/swagger-ui.html

        to browse description of RESTful API.

        You can also visit

        http://localhost:8082

        to browse Demonstrator Dashboard.

        You can also use Catalog QT CLI application
        to perform calls to the API.

        By default, this container starts five services
        
        - MySQL
        - Catalog QT WS
        - Catalog QT Update Process
        - Demonstrator Dashboard
        - inotify based trigger for data imports
 
        ------------------------------------------------
EOF

sudo /etc/init.d/mysql start
sudo /etc/init.d/catalogqt start
sudo /etc/init.d/updateprocess start
sudo /etc/init.d/imas-inotify start
sudo /etc/init.d/dashboard start

/bin/bash

