# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.

The easiest, fastest way to get it running follows

```
> git clone https://github.com/mkopsnc/catalogue_qt_docker.git
> cd docker-compose/build
> ./build.sh
> docker-compose up
```

# Prepare your work environment

In order to build this container, you will need access to few repositories. This container is based on:

- `imas/ual`
- `catalog_qt_2`
- `demonstrator-dashboard`
- `imas-inotify`

## Make sure you can access imas/ual
 
This `Catalogue Qt 2 Docker` image is based on `imas/ual` Docker image. It is available from Docker registry

```
rhus-71.man.poznan.pl
```

Before you proceed, make sure you can access the registry. You can test it by executing following command

```
docker login rhus-71.man.poznan.pl
```

You will be asked for a user name and password. If you don't have it, contact developer of this project.

## Make sure you can access catalog_qt_2

You will also need an access to `catalog_qt_2` project. Make sure you can access it.

```
> git clone https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2 
```

## Make sure you can access demonstrator-dashboard

Demonstrator-Dashboard is a UI part of the whole solution. It is hosted on gitlab as a separate project. Make sure to ask for an access to this project and double check whether you can get the source code or not.

```
> git clone https://gitlab.com/fair-for-fusion/demonstrator-dashboard
```

## Make sure you can access imas-inotify project

This repository is publicly available. All you have to do, is to double check whether you can clone it

```
> git clone https://github.com/tzok/imas-inotify.git
```

***

# Building and running container

In order to build and run container you have to do following

```
> cd docker-compose/build
> ./build.sh
> cd ..
> docker-compose up 
```

***

# Starting container

Starting the container is quite simple, all you have to do is to run

```
> docker-compose run
```

- [localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [localhost:8082](http://localhost:8082) to access Demonstrator Dashboard

# Importing data from pulse file

Catalog QT Demonstrator allows to import MDSPlus based data automatically into SQL database. In order to do this you have to bind mount a volume. In a plain text it means that you have to tell Docker that you want to make your local filesystem to be available inside Docker container. Easiest way to do it is to create directory (or symbolic link) to a MDSPlus compatible local database.

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

Once you have it, create a symbolic link insde docker-compose directory and run container

```
> docker-compose run
```

This way, you have bind mounted your local filesystem inside Docker container. Once Docker is running you can schedule data population by creating file with `*.populate` extension.

```
> echo "" > imasdb/test/3/0/ids_10001.populate
```

# Setting up external volume for MySQL data

TBD

# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 and Demonstrator Dashboard source repositories.
