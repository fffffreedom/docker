# tips

## set insecure-registry for dockerd

### centos 7
```
vim /etc/sysconfig/docker
INSECURE_REGISTRY='--insecure-registry=docker-hostname'
```

### Ubuntu 14.04.2
```
vim /etc/default/docker
DOCKER_OPTS="--insecure-registry=docker-hostname"
```
