# Catalogue QT Docker

This container is desined to simplify debugging process of Catalogue QT services and Catalog QT client application. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.

# Getting Docker file for Catalog QT image

This container requires `imas/ual` Docker image. Before you proceed, make sure to have it installed on your system.

```
> docker login rhus-71.man.poznan.pl
> docker pull rhus-71.man.poznan.pl/imas/ual
> docker tag rhus-71.man.poznan.pl/imas/ual imas/ual:latest
```

Once you have it, you can clone `catalogue_qt_docker` repository

```
> git clone https://github.com/mkopsnc/catalogue_qt_docker.git
> cd catalogue_qt_docker
```

# Things to do, before you have started building the container.

## Make sure to prepare sources of `Catalogue QT 2`

```
> git clone \
  https://YOUR_USER_NAME@gforge-next.eufus.eu/git/catalog_qt_2 
  
> tar cf external/catalog_qt_2.tar ./catalog_qt_2
```

# Building container

Once `Catalog QT 2` is in place, you can build the container.

```
> docker build -t catalogqt .
```

Please note that for tagged release you have to specify tag of the `imas-notify` project. You can do it following way

```
> docker build -t catalogqt --build-arg INOTIFY_TAG=0.4 .
```

# Starting container

Starting the container is quite simple, all you have to do is to run

```
> docker run -i -t --name catalogqt_test catalogqt
```
Once inside, you are "logged in" as user `imas`. All `Catalogue QT` related services are started automatically.

## Exposing Spring Boot based Web Services to the outside world

If you want to access `Catalog QT WS API` outside of the container, you can expose its ports:

```
> docker run -i -t -p 8080:8080 --name catalogqt_test catalogqt
```

## Exposing MySQL ports

For development purposes it might be useful to access data directly inside MySQL instance. You can do it following way

```
> docker run -i \
  -p 8080:8080 \
  -p 3306:3306 \
  -p 33060:33060 \
  --name catalogqt_test -t catalogqt
```

Once container is started you can navigate to:

- [localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.

# Importing data from pulse file

Catalog QT Demonstrator allows to import MDSPlus based data automatically into database. In order to do this you have to bind mount a volume. In a plain text it means that you have to tell Docker that you want to make your local filesystem to be available inside Docker container. You can do it with `-v` option.

First of all, make sure you have `MDSPlus` like directory structure with pulse files.

```
imasdb
`-- test
    `-- 3
        |-- 0
        |   |-- ids_10001.characteristics
        |   |-- ids_10001.datafile
        |   `-- ids_10001.tree
        |-- 1
        |-- 2
        |-- 3
        |-- 4
        |-- 5
        |-- 6
        |-- 7
        |-- 8
        `-- 9
```

Once you have it, you can run Docker container following way

```
> docker run -i \
  -p 8080:8080 \
  -p 3306:3306 \
  -p 33060:33060 \
  -v `pwd`/imasdb:/home/imas/public/imasdb \
  --name catalogqt_test -t catalogqt
```

This way, you are bind mount your local filesystem inside Docker container. Once Docker is running you can schedule data population by creating file with `*.populate` extension.

```
> touch imasdb/test/3/0/ids_10001.populate
````

# Setting up external volume for MySQL data

In case of large data sets you might be interested in storing data outside Docker container. It is possible by attaching your local directory to `/usr/local/mysql/mysql_storage`

> Note that this is a subject to change in the future. Location was choosen arbitraly and may change in the future. It doesn't matter where your local files will be stored, you can choose any location you like

Once you have a place for local data storage you can run Docker following way

```
> docker run -i \
  -p 8080:8080 \
  -p 3306:3306 \
  -p 33060:33060 \
  -v `pwd`/imasdb:/home/imas/public/imasdb \
  -v `pwd`/mysql_storage:/usr/local/mysql/mysql_storage \
  --name catalogqt_test -t catalogqt
```

# Running in debug mode

Inside container there are thress Java process that can be attached to:

- catalogAPI - UpdateProcess,
- catalogAPI - AddRequest (triggered by imas-inotify),
- Spring Boot based Web Services.

In order to make it possible to debug these processe, there are few things you have to do

## Enabling debug mode for components

Make sure to run Docker container such way it exposes ports used for debugging

```
> docker run -i \
  -p 8080:8080 \
  -p 3306:3306 \
  -p 33060:33060 \
  -p 32887:32887 \
  -p 32888:32888 \
  -p 32889:32889 \
  -v `pwd`/imasdb:/home/imas/public/imasdb \
  -v `pwd`/mysql_storage:/usr/local/mysql/mysql_storage \
  --name catalogqt_test -t catalogqt
```

Ports (for remote debugger) were arbitrary choosen:

- `32887` - catalogAPI - AddRequest
- `32888` - catalogAPI - UpdateProcess
- `32889` - Spring Boot application

### Enabling debug for AddRequest

In order to enable debug mode for `AddRequest` code make sure to updated file

```
files
`-- imas-inotify
    `-- config.ini
```

Uncomment the following line

```
; debug = '-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32887'
```

Once uncommented, you will be able to attach using port `32887` and debug all calls to `catalogAPI` executed in `AddRequest` mode.

Note that this is a blocking action. Your container will always wait for debugger to connect whenever new data are ready for being populated.

Alternatively you can pass environment variable: `DEBUG_IMAS_INOTIFY`

```
-e DEBUG_IMAS_INOTIFY=true
```

in that case, default settings for debugger will be used:

```
-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:32887
```

### Enabling debugger for UpdateProcess

Enabling `UpdateProcess` debugging can be done by passing environment variable to container

```
-e DEBUG_UPDATE_PROCESS=true
```

Note that only value `true` is treated as proper flag value for turning on `UpdateProcess` debugger. Any other values will be skipped. Once debugger is started you will be able to attach using port `32888`.

### Enabling debugger for Spring Boot based Web Services

Enabling `Spring Boot` application inside Docker container you have to pass following variable while starting Docker.

```
-e DEBUG_SPRING_BOOT=true
```

Note that only value `true` is treated as proper flag value for turning on `Spring Boot` debugger. Any other values will be skipped. Once debugger is started you will be able to attach using port `32889`.

# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2.

