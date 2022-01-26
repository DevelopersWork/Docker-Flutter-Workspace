# Docker-Flutter-Workspace
![Docker Automated build](https://img.shields.io/docker/automated/developersworkd/flutter-workspace?logo=docker&style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/developersworkd/flutter-workspace?logo=docker)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/developersworkd/flutter-workspace?logo=docker)

[Flutter Workspace](https://hub.docker.com/r/developersworkd/flutter-workspace) is a docker image to develop the flutter applications

## Usage

### create docker-compose.yml
```yaml
version: '3.8'
services:
  flutter-workspace:
    image: developerswork/flutter-workspace
    container_name: flutter_workspace
    volumes:
      - ./workspace:/home/developer/workspace:cached
    command: /bin/sh -c "while sleep 1000; do :; done"
```
### command
```console
docker-compose up -d
```

## Contributing

Before submitting pull requests or issues, please check github to make sure an existing issue or pull request is not already open.
