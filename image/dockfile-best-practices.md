# dockfile-best-practices

## reference

### official suggestion
https://docs.docker.com/engine/reference/builder/  
https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

### 如何编写最佳的Dockerfile

如何编写最佳的Dockerfile  
https://blog.fundebug.com/2017/05/15/write-excellent-dockerfile/  

7 步精简 Docker 镜像  
https://blog.csdn.net/qq_36763896/article/details/53293088  
http://blog.163yun.com/archives/1402  

## 总结

- 编写.dockerignore文件（忽略不打进镜像的文件）  
- 选择合适的base镜像（scratch镜像只能用于构建镜像）  
- 合并RUN指令（效果很好）  
- 每个RUN指令后删除多余的文件（如删除安装包: yum clean all or rm FILES）
- 分离出高频变化的层，并将其独立出来，尽量放到dockerfile的最后  
- 压缩镜像（docker export or docker-squash）  
- 提取动态链接的 .so 文件（效果很好，使用ldd工具查看依赖的so文件，将其拷贝到镜像中）
- 选用更合适的开发语言，比如GO（见《7 步精简 Docker 镜像》）

## CMD & RUN

- CMD指定一个容器启动时要运行的命令，RUN则是构建镜像时运行的命令；

## CMD

- 每个dockerfile可以有多个CMD，但只有最后一个有效；  
- CMD可以被docker run指定的命令覆盖；
- CMD可以有两种写法：CMD ["ls", "-l"] or CMD ls -l，使用前者，后者等价于CMD ["/bin/sh" "-c" "ls -l"]；  

## ENTRYPOINT & CMD

- CMD可以被docker run指定的命令覆盖，而ENTRYPOINT指定的命令则不会被覆盖(可以使用--entrypoint标志来覆盖)；  
- docker run的参数会被当作ENTRYPOINT指定命令的参数；
- ENTRYPOINT语法：ENTRYPOINT ["ls", "-l"]
- ENTRYPOINT和CMD一起使用，前者指定命令，后者指定参数，在docker run时不指定命令和参数，就会使用默认的：  
```
ENTRYPOINT ["ls"]
CMD ["-la"]
```

## 编译命令
```
docker build --help

for example:
docker build -f /path/to/dockfile -t fffffreedom/centos:1.0.0 .
cat dockerfile | docker build -f /path/to/dockfile -t fffffreedom/centos:1.0.0 -
```

## tips

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
WORKDIR
```
