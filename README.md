# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.

# Building container

This container requires `imas/fc2k` Docker image. Before you proceed, make sure to install it on your system. You can follow instructions here: [Installing IMAS Docker](https://docs.psnc.pl/display/WFMS/IMAS+@+Docker). Once you have it installed on your system, you can create `Catalogue QT Docker`.

```
> git clone https://github.com/mkopsnc/catalogue_qt_docker.git
> cd catalogue_qt_docker
```

# Things to do, before you have started building the container.

## Make sure to prepare sources of `Catalogue QT 2`

```
> git clone --single-branch --branch develop https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2 
> tar cf external/catalog_qt_2.tar ./catalog_qt_2
```

## Make sure to prepare source of `Demonstrator Dashboard`

```
> git clone --single-branch --branch api_calls https://gitlab.com/fair-for-fusion/demonstrator-dashboard
> tar cf external/demonstrator-dashboard.tar ./demonstrator-dashboard
```

# Building container

Once both projects are in place, you can build the container.

```
> docker build -t catalogqt .
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
> docker run -i -p 8080:8080 -p 8082:8082 --add-host=catalog.eufus.eu:127.0.0.1 --name catalogqt_test -t catalogqt
```

## Exposing MySQL ports

For development purposes it might be useful to access data directly inside MySQL instance. You can do it following way

```
> docker run -i -p 8080:8080 -p 8082:8082 -p 3306:3306 -p 33060:33060 --add-host=catalog.eufus.eu:127.0.0.1 --name catalogqt_test -t catalogqt
```

Once container is started you can navigate to:

- [localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [localhost:8082](http://localhost:8082) to access Demonstrator Dashboard

# Importing data from pulse file

TBD

# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 source repository.
