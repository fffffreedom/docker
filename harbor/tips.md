# tips

## set insecure-registry for dockerd

centos 7上
```
vim /etc/sysconfig/docker
INSECURE_REGISTRY='--insecure-registry=docker-hostname'
```
