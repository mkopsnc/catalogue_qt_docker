# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.


## Known limitations

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 and Dashboard-ReactJS source repositories.

***

The easiest, fastest way to get it running follows:

```
> git clone https://github.com/mkopsnc/catalogue_qt_docker.git
> cd docker-compose/build
> ./build.sh
> cd ..
> ./run.sh -s api-noauth -s ui-noauth -s proxy-noauth
```

- [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) to access Web Services via Swagger based UI.
- [http://localhost.dashboard-ui.pl/dashboard/](http://localhost.dashboard-ui.pl:9100/dashboard/) to access Dashboard-ReactJS


***

For further instructions and configuration go to the `/docker-compose` folder in this repository and check out `README.md` file. 
