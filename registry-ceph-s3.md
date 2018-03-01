# docker registry using ceph s3 as storage backend

```
=====================
host config
=====================
vim /etc/sysconf/docker
INSECURE_REGISTRY="--insecure-registry 10.101.17.83:5000"

systemctl restart docker

=====================
s3
=====================
s3aws: SerializationError: failed to decode S3 XML error response
https://github.com/docker/distribution/issues/1745

https://docs.docker.com/v1.12/registry/configuration/
https://docs.docker.com/registry/
https://docs.docker.com/registry/deploying/
https://docs.docker.com/registry/storage-drivers/s3/
http://dockone.io/article/627

docker run -d -v `pwd`/config.yml:/etc/docker/registry/config.yml -p 5000:5000 --restart=always --name registry registry:2

docker run -d -v `pwd`/config.yml:/etc/docker/registry/config.yml -v /etc/hosts:/etc/hosts -p 5000:5000 --restart=always --name registry registry:2

version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  s3:
    accesskey: 14XS46LRV674HXP7TU37
    secretkey: NxN6WPq5bCBNsgCWcXpByZ10Hod8Ba8kPWBDuXcc
	region: us-west-1
    regionendpoint: vstore.com
    bucket: registry
    secure: false
    chunksize: 5242880
    rootdirectory: /registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3

=====================
swift
=====================

radosgw-admin subuser create --uid=docker --subuser=docker:swift --access=full

config.yml

version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  swift:
    authurl: http://10.101.4.21/auth/v1
    username: docker:swift
    password: tZSTH3lQgOihkBYIqvRYV79qKDVYnbzDqH0Roezv
    container: registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3

docker run -d -v `pwd`/config.yml:/etc/docker/registry/config.yml -p 5000:5000 --restart=always --name registry registry:2


================
aws
================
https://forums.docker.com/t/docker-registry-aws-s3-bucket/28374
```
