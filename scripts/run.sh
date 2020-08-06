#!/bin/bash

cd $HOME

cat << EOF
      ****************************************************
          https://github.com/mkopsnc/Catalog-QT-Docker
      ****************************************************
        This Docker container provides functionality
        of IMAS based Catalog QT service.
        ------------------------------------------------
        
        Once started, you can browse:

        http://localhost:8080/swagger-ui.html

        for API.

        You can also use Catalog QT client application
        to perform calls to the API.

        By default, this container starts three services
        
        - MySQL
        - Catalog QT WS
        - Catalog QT Update Process
 
        ------------------------------------------------
EOF

sudo /etc/init.d/mysql start
sudo /etc/init.d/catalogqt start
sudo /etc/init.d/updateprocess start
sudo /etc/init.d/imas-inotify start

/bin/bash

