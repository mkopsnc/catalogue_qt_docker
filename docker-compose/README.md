# Catalogue QT Docker

## Table of contents
* [Local installation](#local-installation)    
  * [Access to repositories](#access-to-repositories)
  * [Building container](#building-container)
  * [Starting container](#starting-container)
* [Configuration](#configuration)
  * [Keycloak](#keycloak)
  * [Catalog QT 2 Configuration Files](#catalog-qt-2-configuration-files)
  * [Docker-compose Configuration](#docker-compose-configuration)
    * [Importing data from pulse file](#importing-data-from-pulse-file)
    * [Adding persistent storage](#adding-persistent-storage)
* [Remote installation](#remote-installation)
  * [Opening ports](#opening-ports)
  * [Setting up a SSL certificate](#setting-up-a-ssl-certificate)
  * [Reverse-Proxy SSL configuration with nginx](#reverse-proxy-ssl-configuration-with-nginx)
  * [Starting container as server](#starting-container-as-server) 
* [Debugging in docker-compose](#debugging-in-docker-compose)
* [Container dependencies](#container-dependencies)
* [Troubleshooting download issues inside Docker](#troubleshooting-download-issues-inside-docker)
***
# Local installation

In order to build this container, you will need access to few repositories. This container is based on:

- `imas/ual`
- `catalog_qt_2`
- `dashboard-ReactJS`
- `imas-watchdog`
- `nginx`


## Access to repositories
### Make sure you can access imas/ual

This `Catalogue Qt 2 Docker` image is based on `imas/ual` Docker image. It is available from Docker registry `rhus-71.man.poznan.pl`.
Before you proceed, make sure you can access the registry. You can test it by executing following command

```
> docker login rhus-71.man.poznan.pl
```

You will be asked for a user name and password. If you don't have it, contact developer of this project.



### Make sure you can access dashboard-ReactJS

Docker image that contains Dashboard application can be downloaded from a Docker registry `registry.apps.man.poznan.pl`.
Before you proceed, make sure you can access the registry. You can test it by executing following command

```
> docker login rhus-71.man.poznan.pl/f4f/dashboard-ui/assets:branch-develop
```


### Make sure you can access catalog_qt_2

You will also need an access to `catalog_qt_2` project. Make sure you can access it. 
To do so, please go to folder `docker-compose/build` and in there execute this command:

```
> git clone --single-branch --branch=develop https://YOUR_USER_NAME@gforge-next.eufus.eu/git/catalog_qt_2 
```

You will be asked for a user name and password. If you don't have it, contact developer of this project.



### Make sure you can access imas-watchdog project

This repository is publicly available. All you have to do, is to double check whether you can clone it in `docker-compose/build` folder.

```
> git clone --single-branch --branch=master https://github.com/tzok/imas-watchdog.git
```

## Make sure you have proper `/etc/hosts/`

Your `/etc/hosts/` must have this line in it for proper collaboration with Keycloak  
```
 > cat /etc/hosts
# Host addresses
127.0.0.1  localhost.dashboard-ui.pl
...

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


- api-allconfig.yml - all avaiable configuration in one file (you can comment particular lines to disable functionalities)  
- api-debug.yml - configured for running Docker compose in debug mode (Web Services, Update Process, Scheduler)  
- api-noauth.yml - configured for running Docker compose in single-user mode (no tokens are used for authorization/authentication)  
- api-remote.yml - configuration for instalation on remote machines  
- proxy-noauth.yml - reverse-proxy configuration without SSL, which **disables** secured UI in webbrowser  
- proxy-auth-domain.yml - reverse-proxy configuration with SSL, which **enables** secured UI in webbrowser for particular domain  
- ui-auth.yml - UI with keycloak and TLS authentication  
- ui-noauth.yml - UI without any authorization, for local instalation  
- ui-remote-chara.yml - configuration for instalation on remote chara machine with its own keycloak instance    


You can run given configuration by calling

```
> cd docker-compose
# ./run.sh -s <configuration file suffix> e.g.
```


The most basic execution of our Catalog QT 2 on local machine is:

```
> ./run.sh -s api-noauth -s ui-noauth -s proxy-noauth
```

To access our application please paste this urls in your browser:

- [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [http://localhost:9100/dashboard/](http://localhost:9100/dashboard/) to access User-friendly Interface

***
# Configuration

## Keycloak

Keycloak is an open-source user authentication and authorization server.  
If you want to integrate Catalog QT installation with Keycloak, you have to make sure to have it installed and configured.   
For basic usage and testing purposes we suggest using  single user mode installation.

## Catalog QT 2 Configuration Files

Our dockerized application consists of another independent repository - `Catalog QT 2`.

### Catalog QT 2
This repository consists of *Web Services* and *Client mode* used to operate with plasma data.  
It can be downloaded and used **seperaterly**, without docker. 


Catalog QT 2 has its own configuration files in `catalog_qt_2/server/catalog_ws_server/src/main/resources`: 

- `application.properties  -> application.properties.noauth` (the arrow means it is softlinked **at default** to the    
      `application.properties.noauth`, **NOTE!** this file is used **at default**!  )
- `application.properties.auth`
- `application.properties.auth-cert`
- `application.properties.noauth`
- `uri-mapping-feeder.properties`
- `uri-mapping-parser.properties`
- `url.properties`



This files can be easily editable at docker side.  
All of the files above are also at deafult in  `docker-compose/volumes/server-properties`, where you can edit them as you like.   
(You can turn on SSL, disable token verification to some URL, etc. - it is explained in next section).

In your `docker-compose._deployment_name_.yml` in **server** section there should be these lines:
```
server:
  volumes:
    - ./volumes/server-properties:/home/imas/server-properties 
```

It means that files in `/server-properties` are mapped and seen in docker,  
where are properly injected to Cataloq QT 2 codes and they **OVERRIDE** settings in Catalog QT 2 `/resources` inside docker.

If you edit some of the files, all you need to do is to rerun docker. e.g:

```
./run.sh -s api-noauth -s ui-noauth -s proxy-noauth
```

Thanks to this approach you don't have to edit config files inside `docker-compose/build/catalog_qt_2/server/catalog_ws_server/src/main/resources` folder and rebuild whole docker, which takes a lot of time.   
Now this process is very fast and user friendly.



#### Anatomy of `application.properties`
```
#conatiners in docker are connected via 'db' not 'localhost'
spring.datasource.url=jdbc:mysql://db:3306/itm_catalog_qt?serverTimezone=UTC

# Default user name and password for database connection. Note that this connection
# will not work (by default) for external hosts. This is why we don't quite care about
# user/pass - however, you can alter these and make sure they don't contain default values
spring.datasource.username=itm_catalog_rw
spring.datasource.password=itm_catalog_rw
spring.jpa.properties.hibernate.jdbc.time_zone=UTC

# In case of errors we want to embed error message as well (so we better know what went wrong)
server.error.include-message=always

# We definitely don't want to log SQL queries. However, if you want to see them, feel free
# to enable this property
spring.jpa.show-sql=false

# We don't want to generate DB schema from bean classes
spring.jpa.hibernate.ddl-auto=none

# This is additional http handler, on another port
# We need this one, in case we plan to use https

# This is tricky :)
# If server.ssl fields are set, this field defines https port
# If server.ssl fields are not set, this field defines http port
#HTTPS PORT
server.port=8443

# However, we need http port anyway (for some components). This is why we expose services on
# http anyway. At the and we can end up with two different configurations
# http  (8081) and http (8080) - no certificates
# https (8443) and http (8080) - certificates 
server.http.port=8080
server.http.interface=0.0.0.0

# ------- Keycloak settings -------

keycloak.enabled=true

keycloak.realm = fair4fusion-docker-demo
keycloak.auth-server-url=https://sso.apps.paas-dev.psnc.pl/
keycloak.resource= catalogqt-cli
keycloak.realm-key= MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjOCDGJsBi7rxVjf0RQb8pm0LAGsEKFcH7g7mKSqpFvp1uOypUeiYe5dwlwkXAXaYeYs0J70LB8E6mtVUcykbmp+XrqD1nn3yfPxlVLSg7iCvJqMUq8udsUbsyT3M/32/kssXurgY7rX5JhdtkYeAgq+9ifIjLQZhALg+FvEsX9C+D30WQDAChEljlReb+Y4UTz2aIqz9C+90bqG1ZIX4o3Dli1PZDosTNM444CwDTbrFrenctOTDtGPodo9k2jze8McZFAIrdUYi9mKD8v0frs8NUUW/TQj9h62swXdvVAfzYTd+R7aMRG0eXMV3rJc38DfsCsF7bkqSg0b4l8GcaQIDAQAB
keycloak.bearer-only = true
keycloak.public-client=true
keycloak.principal-attribute=preferred_username

spring.mvc.dispatch-options-request=true

# ------- HTTPS settings --------

# If you plan to use HTTPS, make sure to uncomment this one
# You have to make sure to generate and configure SSL certificate for your domain
#server.ssl.key-store=file:///home/imas/cert/keystore.p12
#server.ssl.key-store-password=catalogqt
#server.ssl.keyStoreType=PKCS12
#server.ssl.keyAlias=tomcat

# ------- Bearer token authorization --------

# Should we check authorization header or not. This feature toggle enables sort of "single user mode"
# It's useful in case you don't have Keycloak and don't care about user roles. Once set to "false"
# it will make Web Services behave as if there is only one user
swagger-ui.authorization.header=true
```


#### Anatomy of `url.properties`

This file consists of URLs that are avaiable in our API.   
URLs that exists in this file and aren't commented or deleted are authenticated with tokens, only if keycloak is on.  
If you have keycloak enabled (thus you can verify tokens) and you **comment/delete** some of the URLs you disable the token authorization of those deleted URLs.  

`url_1=GET;/annotation;read` - this is the example url, which consists of:
- one of `CRUD` methods: `GET`, `POST`, `PUT`, `DELETE` 
- URL e.g.: `/annotation`
- role permission: `read` or `write`

At default all of the URLS are enabled.

```
url_1=GET;/annotation;read
url_2=GET;/annotation/get-by-experiment/*;read
url_3=GET;/annotation/*;read
url_4=POST;/annotation/add-by-experiment;write
url_5=POST;/annotation;write
url_6=PUT;/annotation/*;write
url_7=DELETE;/annotation/*;write

etc etc...
```

#### Anatomy of `uri-mapping-feeder.properties` and `uri-mapping-parser.properties`

This files are used to properly inject format of plasma data.  
For now avaiable formats are: `UDA` and `MDSPLUS`.  

You can add your own format as another plugin.

***
## Docker-compose Configuration

**Note!** If you're not familiar with docker enviroment, please remember that building and running are diffrent!     
If you have already build container, you can change some of the configuration of containers without rebulding whole docker, which save a lot of time.  
To do so open configutation file `docker-compose._deployment_name_.yml` and change if you wish:

- The path where MySQL will store the data (default: `$(pwd)/db-data`)
- The path where pulsefiles are stored on the host (default: `$(pwd)/imasdb`)
- To map MySQL port to host port, so you can access the database from the container (by deafult no ports are exposed)
- edit custom configuration of Web Services

Additionally you can  create your own e.g `docker-compose.myconf.yml` and run it!
```
> ./run.sh -s myconf
```  


 **Please look at `docker-compose.allconfig.yml` to see all avaiable configurations**  


### Importing data from pulse file

Catalog QT Demonstrator allows to import MDSPlus based data automatically into SQL database. In order to do this you have to bind mount a volume. In a plain text it means that you have to tell Docker that you want to make your local filesystem to be available inside Docker container. Easiest way to do it is to create directory (or symbolic link) to a MDSPlus compatible local database.

First of all, make sure you have `MDSPlus` like directory structure with pulse files. The easiest way to execute Docker container with sample data is to get sample data from `box.psnc.pl` - these are completely artificially created data prepared by testing framework.

```
> curl -L -s \
    -o f4f_data.tar.gz \
    "https://box.psnc.pl/f/a0e76d1063/?raw=1"
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


#### External experiment data folder
If you mount data in folder that is inside `catalogue_qt_docker` the data can be lost if you delete `catalogue_qt_docker` folder.  
To avoid this, you can have external folder with data outside repo, and mount to docker.  
Thanks to it, you don't have to copy data everytime to `catalogue_qt_docker` after downloading. 

```
.
|-- catalogue_qt_docker
`-- experiment_data

```
And then in your `docker-compose.api-<config_file>.yml` you can add:  

``` 
services:
  server:
    volumes:
       ~/workspace/experiment_data/:/home/imas/public/imasdb
```




### Adding persistent storage

You can add persistent storage by setting it up inside `docker-compose.yml` file  

```
services:
  db:
    volumes:
      - ./volumes/mysql:/var/lib/mysql
```

It is not required to link `./volumes/mysql` location. In case you are using some other location for persistent data, feel free to use it instead.  
If you would like to generate DB from scratch you would have to delete this `./volumes/folder` by hand and rerun docker-compose


# Remote installation

You can use our codes on remote host machine in two ways:
- without any authentication
- with TLS/SSL authentication

**Note!**  Get a domain! This would be the best, instead of using an IP adress.

Our domain name for remote example machine installation is: **chara-47.man.poznan.pl**

If you want to use it without authentication:
 - download, configure and build as said above
 - make sure you have opened 80 port to the ouside world on your host machine,

Otherwise, if you want to use is in secured mode, please do so:
- set up SSL certificate
- move certificates to docker volume
- make sure you have opened 443 port to the ouside world on your host machine


## Opening ports

On linux machine you could use `iptables` tool open particular ports.

To list which ports are opened run the below command
```
iptables -L
```

If these ports aren't open run the following command to allow traffic on port 80 and:
```
sudo iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```


Run the following command to save the iptables rules:
```
sudo service iptables save
```


Use the following one-line command to open the open the firewall ports:
```
sudo sh -c "iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT && iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT && service iptables save"
```

## Setting up a SSL certificate

**Note!** Remember - to obtain an SSL certificate you must have a domain!

The best way to obtain an SSL certificate is to use certbot. You can get certbot in multiple ways described https://certbot.eff.org/docs/install.html.

After installation, you need to obtain the raw `.pem` certificate and convert it to `.p12`. Do this by running 
```
certbot certonly --standalone 
```
Provide required information about your domain.

Required files will be located in /`etc/letsencrypt/live/name_of_your_domain` .

Go to this folder and run the command below. 

```
openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out keystore.p12 -name tomcat -CAfile chain.pem -caname root
```

You will be asked to provide a password. Remember it as you will have to enter it in the `application.properties`.  
The output file `keystore.p12` is the file that has all the required information to set up SSL.

In `application.properties` enter this information:

```
server.ssl.key-store=/home/imas/certs   
server.ssl.key-store-password="password to keystore.p12 file"
```

Congratulations! You have set up an SSL certificate!

### Moving SSL certificates to `/volumes/certs`  

Firstly, create a directory if doesn't exists
```
cd catalogue_qt_docker/docker-compose/volumes
mkdir certs
```
Then go to your `/etc/letsencrypt/live/name_of_your_domain` and execute:
 ```
 > ll
 -rw-r--r-- 1 root root  692 Oct 13 08:30 README
lrwxrwxrwx 1 root root   46 Oct 28 21:21 cert.pem -> ../../archive/name_of_your_domain/cert3.pem
lrwxrwxrwx 1 root root   47 Oct 28 21:21 chain.pem -> ../../archive/name_of_your_domain/chain3.pem
lrwxrwxrwx 1 root root   51 Oct 28 21:21 fullchain.pem -> ../../archive/name_of_your_domain/fullchain3.pem
-rw------- 1 root root 5.7K Oct 28 21:22 keystore.p12
lrwxrwxrwx 1 root root   49 Oct 28 21:21 privkey.pem -> ../../archive/name_of_your_domain/privkey3.pem

 ```
As you can see these are soft links to proper certificates file. 
In this case these files have numbers in its name (number of last renewed certificate).

To properly mount our cert files to docker container, we need to copy those files to our `/volumes/certs`, **not symlinks**.
We need to copy 3 files:
- keystore.p12
- cert3.pem
- privkey3.pem

**Note!** Of course in your case the numbers in filenames would be diffrent so remember to change them!

``` 
> pwd 
/etc/letstencrypt/your_domain_name/

> cp keystore.p12 ~/catalogue_qt_docker/docker-compose/volumes/certs
> cp ../../archive/domain-name/cert3.pem ~/catalogue_qt_docker/docker-compose/volumes/certs
> cp ../../archive/domain-name/privkey3.pem ~/catalogue_qt_docker/docker-compose/volumes/certs
```

Check if copying finished successfully
```
> cd ~/catalogue_qt_docker/docker-compose/volumes/certs
> ls -1

keystore.p12
cert3.pem
privkey3.pem
```

## Reverse-Proxy SSL configuration with nginx 

Reverse proxy enables us to properly distinguish urls and ports in our containerized enviroment.  
Please change this files to properly configure reverse-proxy.

### `volumes/nginx-ssl`

**Note!** Please update names of cert files, to be the same as the ones in `/volumes/certs`
```
server {
    listen 443 ssl;
    server_name your_domain_name;  #change your domain name 
    ssl_certificate /etc/nginx/certs/cert3.pem; 
    ssl_certificate_key /etc/nginx/certs/privkey3.pem;
    
..... rest stays the same ....

}

```


### `docker-compose.proxy-auth-domain.yml`
```
version: "3.6"
services:
  proxy:
    image: nginx
    volumes:
    
    #This is our directory for nginx configuration
      - ./volumes/nginx-ssl-chara:/etc/nginx/conf.d:ro
      
     #This is where our certs are mounted 
      - ./volumes/certs:/etc/nginx/certs:ro
    ports:
      - 443:443
    depends_on:
      - server
      - react

  react:
    environment:
    #This is our domain name 
      - CATALOG_QT_API_URL=https://your_domain_name/api  #change your domain name
```


### `docker-compose.api-remote.yml`
Please open (or copy and rename) this file and configure with proper monuting folders for your experiment data etc.



So now you are ready to run Catalog QT 2 on remote host!
***
### Starting container as server

- without SSL/TLS
```
./run.sh -s api-noauth -s ui-noauth -s proxy-noauth
```  

http://your-domain-name/dashboard/  
https://your-domain-name/api/swagger-ui.html/  


http://chara-47.man.poznan.pl/api/swagger-ui.html  
http://chara-47.man.poznan.pl/dashboard/




- with SSL/TLS and if you have Keycloak enabled
```
./run.sh -s api-remote -s ui-auth -s proxy-auth

```  
https://your-domain-name/dashboard/  
https://your-domain-name/api/swagger-ui.html/  
  
https://chara-47.man.poznan.pl/api/swagger-ui.html  
https://chara-47.man.poznan.pl/dashboard/

You will see login page. You can login with:
`(user:pass - demo001:demo001)`
or your LDAP account.

***


# Debugging in docker-compose

You can debug either all the Java based components, inside Docker container, or you can specify which one should be started in debug more. For debugging Java code inside Docker containers we are using `JDWP` protocol, and by default we are using following ports

```
Catalog QT 2 (Web Serwices, Client etc)  - 32889
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
      - /path/to/your/directory/catalog_qt_2/server/catalog-ws-server:/catalog_qt_2/server/catalog-ws-server #1
    ports:
      - 32889:32889 
    environment: 
      - DEBUG_SPRING_BOOT=true 
```

If you want to develop Catalog QT 2 codes in a easy way with connection to container you should:

1. Clone the repo of `catalog_qt_2` outside `catalogue_qt_docker` directory (e.g. `/Desktop`).
2. Run `./compile.sh` script in chosen folder directory.
3. Map your choosen directory path on localhost to directory of `catalog_qt_2` codes on `docker-compose_server_1` container directory  .
   This is what `#1` line is doing.  
4. Rerun container.
5. You will see that Spring isn't taking off - that means it waits for a remote debbuger to connect!
6. Go to your IDE - we are using Intellij IDE.   ![image](https://user-images.githubusercontent.com/34068433/125778110-2a41eda3-5ab6-46bf-98ad-c64221434c9c.png)
   a. top left corner -> click `+` `Add new configuration`   
   b. choose `Remote JVM Debug`  
   c. set settings as in a screen shot above (**Important!!** change port to **32889** or diffrent one set in `docker-compose.####.yml`    
   d. run debug mode in IDE with proper configuration  
7. In your konsole you will see that Spring is taken off!
8. Go to your IDE and set breakpoint
9. In Swagger or Postman send proper request on port 8080


**If this works - bravo!! You're ready to debug!**

If you change some codes, you need to recompile the source codes.   
To do so 

```
cd ~/catalog_qt_2   #or whenever you have your mapped folder

./clean.sh ; ./compile_server.sh

```

It takes few seconds, after that you need to rerun docker.

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


# Container dependencies

![](auxilliary/dependencies.svg)

-   Container `server` connects to `db`. The connection URL is in file: `catalog_qt_2/server/catalog-ws-server/src/main/resources/application.properties` in line:

    ```
    spring.datasource.url=jdbc:mysql://db:3306/itm_catalog_qt?serverTimezone=UTC
    ```

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
