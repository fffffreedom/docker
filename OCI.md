# OCI
## 前言--容器引擎
what? 什么是容器引擎？容器引擎不就是docker么？  
其时，除了docker之外，还有coreos的rkt，以及阿里的pouch等，那有这么多不同的引擎，怎么玩？  
如果每个容器厂商都有自己独自的生态圈，那要试试其它家的容器引擎，就要把所有配套的组件都换掉。这样用户会疯的！  
那怎么办呢？没错， 赶紧商讨一个标准或规范，大家共同遵守，这样所有其它的配套组件就可以共用了。  
```
---------------------------------------
监控平台、容器管理portal ...
---------------------------------------
我是标准
---------------------------------------
docker | rkt | pouch | ...
---------------------------------------
我是标准
---------------------------------------
os (linux | windows | ios)
---------------------------------------
```
## 规范--事物发展到一定阶段的产物
随着容器技术发展的愈发火热，Linux基金会于2015年6月成立OCI（Open Container Initiative）组织，
**旨在围绕容器格式（image）和运行时（runtime）制定一个开放的工业化标准。**
该组织一成立便得到了包括谷歌、微软、亚马逊、华为等一系列云计算厂商的支持。  
说白了，OCI就是一个定义容器标准或规范的组织。它是防止各家容器厂商各搞各的，都不一样，不利于容器行业的发展。  
有了规范，各厂商就可以根据规范来完成自已的开发；再加上一个适配层，用户可以灵活地选择。  
制定容器格式标准的宗旨概括来说就是不受上层结构的绑定，如特定的客户端、编排栈等，
同时也不受特定的供应商或项目的绑定，即不限于某种特定操作系统、硬件、CPU架构、公有云等。  
目前，OCI发布了两个规范：
- image-spec:  容器镜像规范  
> https://github.com/opencontainers/image-spec/blob/master/spec.md  

This specification defines an OCI Image, consisting of a manifest, an image index (optional), 
a set of filesystem layers, and a configuration.

The goal of this specification is to enable the creation of interoperable tools 
for building, transporting, and preparing a container image to run.

- runtime-spec:  容器运行时规范
> https://github.com/opencontainers/runtime-spec/blob/master/spec.md    

The Open Container Initiative Runtime Specification aims to specify 
the configuration, execution environment, and lifecycle of a container.

A container's configuration is specified as the config.json for the supported platforms 
and details the fields that enable the creation of a container. 
The execution environment is specified to ensure that applications running inside a container 
have a consistent environment between runtimes along with common actions defined for the container's lifecycle.
## 标准的实现
docker基于OCI运行时标准，实现了containerd和runc；  


## Reference
Docker背后的标准化容器执行引擎——runC  
http://www.infoq.com/cn/articles/docker-standard-container-execution-engine-runc/  
Docker开源容器运行时组件Containerd  
http://www.infoq.com/cn/news/2017/01/Docker-Containerd-OCI-1  
OCI 发布容器运行时和镜像格式规范 V1.0  
http://www.linuxidc.com/Linux/2017-08/146286.htm  
docker、oci、runc以及kubernetes梳理  
https://www.cnblogs.com/xuxinkun/p/8036832.html  
CoreOS VS Docker容器大战，之容器引擎  
http://www.youruncloud.com/blog/138.html  
OCI推出第1个Container技术映像档格式标准  
http://www.linuxidc.com/Linux/2016-05/131277.htm  
Containerd：一个控制runC的守护进程  
http://dockone.io/article/914  
