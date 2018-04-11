# dockfile-best-practices

## reference

### official suggestion
https://docs.docker.com/engine/reference/builder/  
https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

### 如何编写最佳的Dockerfile
https://blog.fundebug.com/2017/05/15/write-excellent-dockerfile/

## 镜像构建实践

### 编译命令
```
docker build --help

for example:
docker build -f /path/to/dockfile -t fffffreedom/centos:1.0.0 .
cat dockerfile | docker build -f /path/to/dockfile -t fffffreedom/centos:1.0.0 -
```

### tips

#### 减小image size的方法

```
yum clean all
```
