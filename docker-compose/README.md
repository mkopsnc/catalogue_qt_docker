# Building the images

Be prepared to:

- Login into `rhus-71.man.poznan.pl` Docker registry
- Login into `gforge6.eufus.eu` project named `catalog_qt_2`
- Login into `registry.apps.man.poznan.pl` Docker registry

```
cd build
./build.sh
```

# Running

Catalogue QT 2 Docker can be run using multiple configurations. By default we provide following configurations

```
production  - configured for production Keycloak instance (eduTEAMS)
development - configured for development based Keycloak instance (user:pass - demo001:demo001)
debug       - configured for running Docker compose in debug mode (Web Services, Update Process, Scheduler)
notoken     - configured for running Docker compose in single-user mode (no tokens are used for authorization/authentication)
```

You can run given configuration by calling

```
./run.sh -s notoken
```

# Configuration

You can edit `docker-compose._deployment_name_.yml` to change:

- The path where MySQL will store the data (default: `$(pwd)/db-data`)
- The path where pulsefiles are stored on the host (default: `$(pwd)/imasdb`)
- To map MySQL port to host port, so you can access the database from the container (by deafult no ports are exposed)
- To add custom configuration of Web Services: `application.properties` file

After changing the settings, it may be necessary to restart from scratch:

```
docker-compose rm
docker-compose up
```

# Container dependencies

![](auxilliary/dependencies.svg)

-   Container `server` connects to `db`. The connection URL is in file: `catalog_qt_2/server/catalog-ws-server/src/main/resources/application.properties` in line:

    ```
    spring.datasource.url=jdbc:mysql://localhost:3306/itm_catalog_qt?serverTimezone=UTC
    ```

    This line is changed by `sed` in Dockerfile to correct value. If you want to change `db` container name in `docker-compose.yml`, then edit the Dockerfile and rebuild `catalogqt/server`.

-   Container `updateprocess` connects to `server`. The connection URL is hard-coded in the main command `/updateprocess.sh` in the last lines:

    ```
    exec java -jar target/catalogAPI.jar \
        -startUpdateProcess \
        --url http://server:8080 \
        --scheme mdsplus \
        --slice-limit 100
    ```

    If you want to change `server` container name in `docker-compose.yml`, then edit `build/files/updateprocess.sh` and rebuild `catalogqt/updateprocess` image.

-   Container `watchdog` connects to `server`. The connection URL is configurable in the `config.ini` file of `tzok/imas-watchdog` project. Currently, the file in `master` branch has a valid URL. If you want to change `server` container name in `docker-compose.yml`, then (1) create a copy of `config.ini` from `tzok/imas-watchdog`, (2) change its `url` line, (3) add `COPY` instruction to Dockerfile's part related to `catalogqt/inotify` and (4) rebuild this image.

-   Container `dashboard` connects to `server` The connection URL is set in `demonstrator-dashboard/db_api/services.py` in line starting with `API_ROOT = `. This line is changed by `sed` in the Dockerfile

# Developer informations

## Debugging in docker-compose

You can debug either all the Java based components, inside Docker container, or you can specify which one should be started in debug more. For debugging Java code inside Docker containers we are using `JDWP` protocol, and by default we are using following ports

```
Web Services   - 32889
Update process - 32888
imas-watchdog  - 32887
```

![](auxilliary/debugging_services.png)

In order to enable debbug mode you can either use predefined `docker-compose.debug.yml` or enable debug mode for each service separatelly by adding sections inside your YAML file of choice.

### Catalog-ws-server

To debug catalog-ws-server you need to add following lines to `docker-compose.####.yml` in `server` section

```yaml
  server:
    volumes:
      - ./volumes/imasdb:/home/imas/public/imasdb
    ports:
      - 32889:32889
    environment: 
      - DEBUG_SPRING_BOOT=true
```

### Update process

To debug update-process you need to add following lines to `docker-compose.####.yml` in `updateprocess` section

```yaml
  updateprocess:
    volumes:
      - ./volumes/imasdb:/home/imas/public/imasdb
    ports:
      - 32888:32888
    environment:
      - DEBUG_UPDATE_PROCESS=true
```

### Watchdog

To debug imas-watchdog you need to add following lines to `docker-compose.####.yml` in `updateprocess` section

```yaml
  watchdog:
    volumes:
      - ./volumes/imasdb:/home/imas/public/imasdb
      - ./volumes/fair4fusion-docker-demo:/docker-entrypoint-properties.d
    ports:
      - 32887:32887
    environment:
      - DEBUG_IMAS_WATCHDOG=true
```

