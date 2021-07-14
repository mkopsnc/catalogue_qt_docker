# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.


**Note!** If you are installing our docker for the first time please go to the next section of this documentation. Otherwise you have access to all of our repositories and can build docker easily as follows: 

```
> git clone https://github.com/mkopsnc/catalogue_qt_docker.git
> cd docker-compose/build
> ./build.sh
> cd ..
> ./run.sh -s notoken
```

***
# Prepare your work environment

In order to build this container, you will need access to few repositories. This container is based on:

- `imas/ual`
- `catalog_qt_2`
- `dashboard-ReactJS`
- `imas-watchdog`


## Make sure you can access imas/ual

This `Catalogue Qt 2 Docker` image is based on `imas/ual` Docker image. It is available from Docker registry `rhus-71.man.poznan.pl`.
Before you proceed, make sure you can access the registry. You can test it by executing following command

```
> docker login rhus-71.man.poznan.pl
```

You will be asked for a user name and password. If you don't have it, contact developer of this project.



## Make sure you can access dashboard-ReactJS

Docker image that contains Dashboard application can be downloaded from a Docker registry `registry.apps.man.poznan.pl`.
Before you proceed, make sure you can access the registry. You can test it by executing following command

```
> docker login registry.apps.man.poznan.pl/f4f/dashboard-ui/assets:branch-develop
```

**Note!** Running Dashboard locally requires an entry inside `/etc/hosts`

```
127.0.0.1       localhost.dashboard-ui.pl
```



## Make sure you can access catalog_qt_2

You will also need an access to `catalog_qt_2` project. Make sure you can access it. 
To do so, please go to folder `docker-compose/build` and in there execute this command:

```
> git clone --single-branch develop https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2 
```

You will be asked for a user name and password. If you don't have it, contact developer of this project.



## Make sure you can access imas-watchdog project

This repository is publicly available. All you have to do, is to double check whether you can clone it in `docker-compose/build` folder.

```
> git clone --single-branch master https://github.com/tzok/imas-watchdog.git
```

 *** 
 
# Building container

In order to build and run container you have to do following

```
> cd docker-compose/build
> ./build.sh
```

**Note!** If you would like to pull the latest codes while rebuiling container please use `-force` flag  
**Note!** If you would like to build without cache use `-no-cache` flag  


# Starting container

Catalogue QT 2 Docker can be run using multiple configurations. By default we provide following configurations

```
production  - configured for production Keycloak instance (eduTEAMS)
development - configured for development based Keycloak instance (user:pass - demo001:demo001)
debug       - configured for running Docker compose in debug mode (Web Services, Update Process, Scheduler)
notoken     - configured for running Docker compose in single-user mode (no tokens are used for authorization/authentication)
```

You can run given configuration by calling

```
> cd docker-compose
# ./run.sh -s <configuration file suffix> e.g.
> ./run.sh -s notoken
```

To access our application please paste this urls in your browser:

- [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [http://localhost.dashboard-ui.pl:9100/dashboard/](http://localhost.dashboard-ui.pl:9100/dashboard/) to access Dashboard-ReactJS

***
# Configuration

### Docker-compose Configuration
You can edit `docker-compose._deployment_name_.yml` to change:

- The path where MySQL will store the data (default: `$(pwd)/db-data`)
- The path where pulsefiles are stored on the host (default: `$(pwd)/imasdb`)
- To map MySQL port to host port, so you can access the database from the container (by deafult no ports are exposed)
- To add custom configuration of Web Services: `application.properties` file

Additionally you can edit existing configuration, or create your own e.g `docker-compose.myconf.yml` and run it!
```
> ./run.sh -s myconf
```

### Catalog QT 2 Web Services Configuration

Moreover, in our `catalog-ws-server` we have `application.properties` file, which is a configuration for our Web Services in Springboot.
The explanation of this file is described here https://docs.psnc.pl/display/WFMS/Administration section `4.4.2.1. Anatomy of application.properties file`

The default configuration is inside our project, but (before building) if you want to use a diffrent configuration (e.g enabling SSL certificates, or changing ports) you can paste in folder `/catalogue_qt_docker/docker-compose/build/files/server` another `application.properties` file, which will have higher priority and would override existing file in source codes and then you can build and run our docker.

If you have already build container, and want to change Web Services configuration, you can do that without rebuilding docker!
All you need to do is to add `application.properties` file to this folder `docker-compose/volumes/server-properties`. 
When the container is taken off, it will have the highest priority.


After changing the settings, it may be necessary to restart from scratch:

```
> docker-compose rm
> docker-compose up
```

*** 
## Adding persistent storage

You can add persistent storage by setting it up inside `docker-compose.yml` file

```
services:
  db:
    volumes:
      - ./volumes/mysql:/var/lib/mysql
```

It is not required to link `./volumes/mysql` location. In case you are using some other location for persistent data, feel free to use it instead.

## Importing data from pulse file

Catalog QT Demonstrator allows to import MDSPlus based data automatically into SQL database. In order to do this you have to bind mount a volume. In a plain text it means that you have to tell Docker that you want to make your local filesystem to be available inside Docker container. Easiest way to do it is to create directory (or symbolic link) to a MDSPlus compatible local database.

First of all, make sure you have `MDSPlus` like directory structure with pulse files. The easiest way to execute Docker container with sample data is to get sample data from `box.psnc.pl` - these are completely artificially created data prepared by testing framework.

```
> curl -s -o f4f_data.tar.gz \
    https://box.psnc.pl/seafhttp/files/01953e73-8ad3-4277-be71-57b69c395355/f4f_data.tar.gz
```

Make sure your directories structure looks like this

```
.
`-- catalogue_qt_docker
    `-- docker-compose
        `-- volumes
            `-- imasdb
                |-- f4f
                |   `-- 3
                |       |-- 0
                |       |   |-- ids_11062020.characteristics
                |       |   |-- ids_11062020.datafile
                |       |   |-- ids_11062020.populate
                |       |   |-- ids_11062020.tree
                |       |   |-- ids_11062021.characteristics
                |       |   |-- ids_11062021.datafile
                |       |   |-- ids_11062021.populate
                |       |   `-- ids_11062021.tree
                |       |-- 1
                |       |-- 2
                |       |-- 3
                |       |-- 4
                |       |-- 5
                |       |-- 6
                |       |-- 7
                |       |-- 8
                |       `-- 9
                `-- script.sh
```

Directory `catalogue_qt_docker/docker-compose/volumes/imasdb` is automatically mounted inside Docker container. It means that anything you have put in it, will be visible inside Docker container whenever it is running. Once Docker is running you can schedule data population by creating file with `*.populate` extension. You can do it following way. Inside directory with data execute `script.sh` with the name of database you want to have populated.

```
> cd catalogue_qt_docker/docker-compose/volumes/imasdb
> ./script.sh f4f
```

<p align="center">
  <img src="https://raw.githubusercontent.com/mkopsnc/catalogue_qt_docker/master/images/docker-compose.gif">
</p>


If anything goes wrong, please delete all the `.populate` files by executing this command on linux:
```
> find . -type f -name "*.populate" -delete  
```
And then try to import data again.
***

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


# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 and Dashboard-ReactJS source repositories.

***

# Troubleshooting download issues inside Docker

It may happen that frame size of network interfaces might be missaligned between your hardware and virtual network creted by Docker. In that case you can experience strange issues with network. For example, your data transfer rate drops to `0 kb/s`. You can examine this missalignment follwoing way: 

```
> ip link
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether ....
148: br-9533f8101c29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff
```

This may lead to issues while transferring data. To solve this issue you may need to change your `/etc/docker/daemon.json` file by adding

```
{
  "mtu": ${SIZE_OF_THE_FRAME_OF_YOUR_NETWORK_DEVICE}
}
```

for the above exaple it will be

```
{
  "mtu": 1458
}
```

If you are using docker-compose you want to modify `docker-compose.yml` as well

```
...
...

networks:
  default:
    driver: bridge
    driver_opts:
      com.docker.network.driver.mtu: 1458

...
...
```

## Restart might be required

In case you have started your container already, you might have your network interface recreated. If you get following error after altering Docker's settings

```
> docker-compose up
ERROR: Network "docker-compose_default" needs to be recreated - option 
  "com.docker.network.driver.mtu" has changed
```

make sure to remove the network and bring everything up again

```
> docker-compose rm
> docker network ls
> docker network rm docker-compose_default # name of your network might depend on your settings
> docker-compose up
```

This should solve your issue, all interfaces should have `MTU` being aligned

```
...
...
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether ... brd ff:ff:ff:ff:ff:ff
148: br-9533f8101c29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc noqueue state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff
150: vetha4ad5b7@if149: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc noqueue master br-9533f8101c29 state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff link-netnsid 0
152: veth8514865@if151: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc noqueue master br-9533f8101c29 state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff link-netnsid 1
154: vethee2a6b9@if153: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc noqueue master br-9533f8101c29 state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff link-netnsid 2
156: vethb90a412@if155: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc noqueue master br-9533f8101c29 state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff link-netnsid 3
158: vethf56cc8a@if157: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1458 qdisc noqueue master br-9533f8101c29 state UP mode DEFAULT group default
    link/ether ... brd ff:ff:ff:ff:ff:ff link-netnsid 4
...
...
```
