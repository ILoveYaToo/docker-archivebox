# docker-archivebox

An alternative [Archivebox](https://archivebox.io) Docker Image running with GUnicorn instead of the developmental WSGI server.

## How to build

The Dockerfile accepts various Archivebox versions and GUnicorn versions as build arguments
```
docker build . --build-arg ARCHIVEBOX_VER=0.6.2 --build-arg GUNICORN_VER=20.1.0
```

## Running

### Bootstraping
```
docker-compose run archivebox archivebox init
```

### Running
```
docker-compose up -d
```

### More Details
If you run outside of docker-compose, all you need to do is mount the `/app/data` folder inside the container somewhere so that the data does not get lost.

