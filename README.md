# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.

# Building container

This container requires `imas/fc2k` Docker image. Before you proceed, make sure to install it on your system. You can follow instructions here: [Installing IMAS Docker](https://docs.psnc.pl/display/WFMS/IMAS+@+Docker). Once you have it installed on your system, you can create `Catalogue QT Docker`.

```
> git clone https://github.com/mkopsnc/catalog_qt_docker.git
> cd catalog_qt_docker
> git checkout --track origin/master
```

Before you start building the container, make sure to prepare sources of `Catalogue QT 2`

```
> git clone https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2
> cd catalog_qt_2
> git checkout --track origin/develop
> cd ..
> tar cf external/catalog_qt_2.tar ./catalog_qt_2
```

Once project is in place, you can build the container.

```
> docker build -t catalogqt .
```

# Starting container

Starting the container is quite simple, all you have to do is to run

```
> docker run -i -t catalogqt
```

once inside, you are "logged in" as user `imas`. All `Catalogue QT` related services are started automatically. If you want to access `Catalog QT WS API` from the outside of the container, you can expose it's ports:

```
> docker run -i -t -p 8080:8080 catalogqt
```

# Starting container and giving access to MySQL

```
> docker run -i -t -p 8080:8080 -p 3306:3306 -p 33060:33060 --name catalogqt_test catalogqt
```

Once container is started you can navigate to: [localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

# Importing data from pulse file

TBD

# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 source repository.
