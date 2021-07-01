# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.

The easiest, fastest way to get it running follows

```
> git clone https://github.com/mkopsnc/catalogue_qt_docker.git
> cd docker-compose/build
> ./build.sh
> cd ..
> ./run.sh -s notoken
```

# Prepare your work environment

In order to build this container, you will need access to few repositories. This container is based on:

- `imas/ual`
- `catalog_qt_2`
- `dashboard-ReactJS`
- `imas-watchdog`

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
> git clone --single-branch develop https://YOUR_USER_NAME@gforge6.eufus.eu/git/catalog_qt_2 
```

## Make sure you can access dashboard-ReactJS

Docker image that contains Dashboard application can be downloaded from `registry.apps.man.poznan.pl`. Make sure you can access it.

```
docker login registry.apps.man.poznan.pl/f4f/dashboard-ui/assets:branch-develop
```

Note! Running Dashboard locally requires an entry inside `/etc/hosts`

```
127.0.0.1       localhost.dashboard-ui.pl
```

## Make sure you can access imas-watchdog project

This repository is publicly available. All you have to do, is to double check whether you can clone it

```
> git clone --single-branch https://github.com/tzok/imas-watchdog.git
```

***

# Building container

In order to build and run container you have to do following

```
> cd docker-compose/build
> ./build.sh
> cd ..
> ./run.sh -s notoken
```

***

# Starting container

Starting the container is quite simple, all you have to do is to run

```
> ./run.sh -s notoken
```

- [localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [localhost.dashboard-ui.pl:9010](http://localhost.dashboard-ui.pl:9010) to access Dashboard-ReactJS

***

# Importing data from pulse file

Catalog QT Demonstrator allows to import MDSPlus based data automatically into SQL database. In order to do this you have to bind mount a volume. In a plain text it means that you have to tell Docker that you want to make your local filesystem to be available inside Docker container. Easiest way to do it is to create directory (or symbolic link) to a MDSPlus compatible local database.

First of all, make sure you have `MDSPlus` like directory structure with pulse files. The easiest way to execute Docker container with sample data is to get sample data from `box.psnc.pl` - these are completely artificially created data prepared by testing framework.

```
> curl -s -o f4f_data.tar.gz \
    https://box.psnc.pl/seafhttp/files/01953e73-8ad3-4277-be71-57b69c395355/f4f_data.tar.gz
```

Make sure your directories structure looks like this

```
.
|-- catalogue_qt_docker
|   |-- docker-compose
|   |-- images
|   `-- single-container
`-- f4f-data
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

Make sure that data directory is linked inside `docker-compose` - we have to make sure that Docker container can see our local data. Once it is done, you can run Docker container.

```
> cd catalogue_qt_docker/docker-compose/volumes/imasdb
> cp -r ../../f4f-data/imasdb/* .
> cd catalogue_qt_docker/docker-compose
> ./run.sh -s notoken
```

This way, you have bind mounted your local filesystem inside Docker container. Once Docker is running you can schedule data population by creating file with `*.populate` extension. You can do it following way. Inside directory with data execute `script.sh` with the name of database you want to have populated.

```
> cd catalogue_qt_docker/docker-compose/volumes/imasdb
> ./script.sh f4f
```

<p align="center">
  <img src="https://raw.githubusercontent.com/mkopsnc/catalogue_qt_docker/master/images/docker-compose.gif">
</p>

***

# Setting up external volume for MySQL data

To use an external volume for MySQL, you need to edit `docker-compose/docker-compose.override.yml` file like here:

```diff
@@ -1,6 +1,10 @@
 version: "3.6"
 
 services:
+  db:
+    volumes:
+      - /path/to/storage:/var/lib/mysql
+
   server:
     volumes:
       - ./imasdb:/home/imas/public/imasdb
```

The added line contains a path to your external volume as seen by the host OS (e.g. `/mnt/vdb1` or `/home/user/catalogqt-mysql`).

If your instance of Catalogue QT is already running, it is advisable to remove it and start from scratch:

```
docker-compose rm
docker-compose up
```

***

# Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 and Demonstrator Dashboard source repositories.

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

This should solve your isse, all interfaces should have `MTU` being aligned

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
