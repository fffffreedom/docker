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

#### docker history

docker history 用来查看一个镜像的build历史，每个层由什么命令创建的等，见下面的示例（可以使用`--no-trunc`查看没有截断的输出）：

```
# docker history jonny/busybox:v3
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
64caf1c4d4e0        15 hours ago        /bin/sh -c echo "export LANG=en_US.UTF-8" >>    1.819 kB            
43b8a9059549        15 hours ago        /bin/sh -c #(nop)  ENV LC_ALL=en_US.UTF-8       0 B                 
b9c8abb2a6ee        15 hours ago        /bin/sh -c #(nop)  ENV LANG=en_US.UTF-8         0 B                 
d3edd11a7601        15 hours ago        /bin/sh -c yum install sysstat -y; yum instal   50.47 MB            
66ee80d59a68        5 months ago        /bin/sh -c #(nop)  CMD ["/bin/bash"]            0 B                 
<missing>           5 months ago        /bin/sh -c #(nop)  LABEL name=CentOS Base Ima   0 B                 
<missing>           5 months ago        /bin/sh -c #(nop) ADD file:940c77b6724c00d420   191.8 MB            
<missing>           5 months ago        /bin/sh -c #(nop)  MAINTAINER https://github.   0 B 
```

Note: The <missing> lines in the docker history output indicate that those layers were built on another system and are not available locally. This can be ignored.  
> https://docs.docker.com/storage/storagedriver/

#### 减小image size的方法

```
yum clean all
```

#### size为0的层

由如下命令生成的镜像层size为0：  
```
ENV
CMD
```
