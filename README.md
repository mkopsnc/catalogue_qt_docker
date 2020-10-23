# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.

# Getting Docker file for Catalog QT image

This container requires `imas/fc2k` Docker image. Before you proceed, make sure to install it on your system. You can follow instructions here: [Installing IMAS Docker](https://docs.psnc.pl/display/WFMS/IMAS+@+Docker). Once you have it installed on your system, you can create `Catalogue QT Docker`.

```
> git clone --single-branch --branch v1.3.2 \
  https://github.com/mkopsnc/catalogue_qt_docker.git
  
> cd catalogue_qt_docker
```

# Things to do, before you have started building the container.

## Make sure to prepare sources of `Catalogue QT 2`

```
> git clone --single-branch --branch v1.3 \
  https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2 
  
> tar cf external/catalog_qt_2.tar ./catalog_qt_2
```

## Make sure to prepare source of `Demonstrator Dashboard`

```
> git clone --single-branch --branch v1.3 \
  https://gitlab.com/fair-for-fusion/demonstrator-dashboard
  
> tar cf external/demonstrator-dashboard.tar ./demonstrator-dashboard
```

***

# Building development version of Docker

> Note that this section is for people who work with development release of Catalog QT - Docker

In case you want to build development version of `Catalog QT - Docker` you have to use following branches

```
> git clone --single-branch --branch master \
  https://github.com/mkopsnc/catalogue_qt_docker.git
  
> cd catalogue_qt_docker
```

```
> git clone --single-branch --branch develop \
  https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2
  
> tar cf external/catalog_qt_2.tar ./catalog_qt_2
```

```
> git clone --single-branch --branch psnc/develop \
  https://gitlab.com/fair-for-fusion/demonstrator-dashboard
  
> tar cf external/demonstrator-dashboard.tar ./demonstrator-dashboard
```

***

# Building container

Once both projects are in place, you can build the container.

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

## Exposing Demonstrator Dashboard

By default, Demonstrator Dashboard ports are not exposed. If you want to access Demonstrator Dashboard, you can do it following way

```
> docker run -i \
  -p 8080:8080 \
  -p 8082:8082 \
  --add-host=catalog.eufus.eu:127.0.0.1 \
  --name catalogqt_test -t catalogqt
```

Also you want to add this line in your `/etc/hosts` file

```
> echo "127.0.0.1     catalog.eufus.eu" | sudo tee -a /etc/hosts
```

## Exposing MySQL ports

For development purposes it might be useful to access data directly inside MySQL instance. You can do it following way

```
> docker run -i \
  -p 8080:8080 \
  -p 8082:8082 \
  -p 3306:3306 \
  -p 33060:33060 \
  --add-host=catalog.eufus.eu:127.0.0.1 \
  --name catalogqt_test -t catalogqt
```

Once container is started you can navigate to:

- [localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [catalog.eufus.eu:8082](http://catalog.eufus.eu:8082) to access Demonstrator Dashboard

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
> docker run -i -p 8080:8080 \
  -p 8082:8082 \
  -p 3306:3306 \
  -p 33060:33060 \
  --add-host=catalog.eufus.eu:127.0.0.1 \
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
> docker run -i -p 8080:8080 \
  -p 8082:8082 \
  -p 3306:3306 \
  -p 33060:33060 \
  --add-host=catalog.eufus.eu:127.0.0.1 \
  -v `pwd`/imasdb:/home/imas/public/imasdb \
  -v `pwd`/mysql_storage:/usr/local/mysql/mysql_storage \
  --name catalogqt_test -t catalogqt
```

# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 and Demonstrator Dashboard source repositories.
