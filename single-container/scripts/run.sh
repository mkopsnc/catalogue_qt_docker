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

         You can also use Catalog QT CLI application
         to perform calls to the API.

         By default, this container starts five services
        
         - MySQL
         - Catalog QT WS
         - Catalog QT Update Process
         - inotify based trigger for data imports
 
        ------------------------------------------------
EOF

# This part is responsible for moving data storage
# to external volume in case it is connected

# We have to make sure that storage exists
if [ -e /usr/local/mysql/mysql_storage ]; then
  # In case we haven't moved data yet, we have to do it
  if [ ! -L /usr/local/mysql/data/itm_catalog_qt ]; then
    sudo mv /usr/local/mysql/data/itm_catalog_qt /usr/local/mysql/mysql_storage
    sudo ln -s /usr/local/mysql/mysql_storage/itm_catalog_qt /usr/local/mysql/data/itm_catalog_qt
  fi
fi

echo "" > /home/imas/opt/etc/services-env

if [ ! -z "$DEBUG_UPDATE_PROCESS" ]; then
  if [[ "${DEBUG_UPDATE_PROCESS}" == "true" ]]; then
    echo "DEBUG_UPDATE_PROCESS=true" >> /home/imas/opt/etc/services-env
  else
    echo "DEBUG_UPDATE_PROCESS=false" >> /home/imas/opt/etc/services-env
  fi
fi

if [ ! -z "$DEBUG_SPRING_BOOT" ]; then
  if [[ "${DEBUG_SPRING_BOOT}" == "true" ]]; then
    echo "DEBUG_SPRING_BOOT=true" >> /home/imas/opt/etc/services-env
  else
    echo "DEBUG_SPRING_BOOT=false" >> /home/imas/opt/etc/services-env
  fi
fi

if [ ! -z "$DEBUG_IMAS_INOTIFY" ]; then
  if [[ "${DEBUG_IMAS_INOTIFY}" == "true" ]]; then
    echo "DEBUG_IMAS_INOTIFY=true" >> /home/imas/opt/etc/services-env
  else
    echo "DEBUG_IMAS_INOTIFY=false" >> /home/imas/opt/etc/services-env
  fi
fi

sudo /etc/init.d/mysql start
sudo /etc/init.d/catalogqt start
sudo /etc/init.d/updateprocess start
sudo /etc/init.d/imas-inotify start

/bin/bash

