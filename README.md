# Catalogue QT Docker

This container is desined to simplify installation of Catalogue QT and it's components. Instead of installing it on `IMAS` compatible platform you can use it on virtually any machine.


## Known limitations - repository access

Note that this container should be used only for research purposes. You need access to Catalogue QT v.2 and Dashboard-ReactJS source repositories.

## Known limitations - M1 based macOS

At the moment we are facing issues with `macOS` and `M1` architecture. While building the image, you will face the issue:

```
failed to solve with frontend dockerfile.v0: failed to create LLB definition: ...
```

Stay tuned, as soon as there is a fix, we will remove this notice.

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
- [http://localhost:9100/dashboard/](http://localhost:9100/dashboard/) to access User-friendly Interface

***

For further instructions and configuration go to the `/docker-compose` folder in this repository and check out `README.md` file. 
