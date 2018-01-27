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
## OCI
The OCI currently contains two specifications: the Runtime Specification (runtime-spec) and the Image Specification (image-spec). 
The Runtime Specification outlines how to run a “filesystem bundle” that is unpacked on disk. 
At a high-level an OCI implementation would download an OCI Image then unpack that image into an OCI Runtime filesystem bundle. 
At this point the OCI Runtime Bundle would be run by an OCI Runtime.  
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
为了支持OCI标准，docker将容器运行时及其管理功能从Docker Daemon剥离，从v1.11版本之后，docker的结构变成了：  
![](https://github.com/fffffreedom/Pictures/blob/master/docker-arch.png)  
containerd主要职责是镜像管理（镜像、元信息等）、容器执行（调用最终运行时组件执行runc）。
runC是Docker的另一个开源项目，它实现了OCI的runtime-spec，容器的实际运行时由它控制。  
## kubernetes与容器 [5]
kubernetes在初期版本里，就对多个容器引擎做了兼容，因此可以使用docker、rkt对容器进行管理。以docker为例，kubelet中会启动一个docker manager，通过直接调用docker的api进行容器的创建等操作。  

在k8s 1.5版本之后，kubernetes推出了自己的运行时接口api--CRI(container runtime interface)。cri接口的推出，隔离了各个容器引擎之间的差异，而通过统一的接口与各个容器引擎之间进行互动。  

与oci不同，cri与kubernetes的概念更加贴合，并紧密绑定。cri不仅定义了容器的生命周期的管理，还引入了k8s中pod的概念，并定义了管理pod的生命周期。在kubernetes中，pod是由一组进行了资源限制的，在隔离环境中的容器组成。而这个隔离环境，称之为PodSandbox。在cri开始之初，主要是支持docker和rkt两种。其中kubelet是通过cri接口，调用docker-shim，并进一步调用docker api实现的。  

由于docker独立出来了containerd，kubernetes也顺应潮流，孵化了cri-containerd项目，用以将containerd接入到cri的标准中。  
![](https://github.com/fffffreedom/Pictures/blob/master/k8s-containerd.png) 
为了进一步与oci进行兼容，kubernetes还孵化了cri-o，成为了架设在cri和oci之间的一座桥梁。通过这种方式，可以方便更多符合oci标准的容器运行时，接入kubernetes进行集成使用。可以预见到，通过cri-o，kubernetes在使用的兼容性和广泛性上将会得到进一步加强。  
![](https://github.com/fffffreedom/Pictures/blob/master/cri-runc-containerd-docker.png)  
## Reference
Docker、Containerd、RunC...：你应该知道的所有  
http://www.infoq.com/cn/news/2017/02/Docker-Containerd-RunC  
Docker背后的标准化容器执行引擎——runC  
http://www.infoq.com/cn/articles/docker-standard-container-execution-engine-runc/  
Docker开源容器运行时组件Containerd  
http://www.infoq.com/cn/news/2017/01/Docker-Containerd-OCI-1  
OCI 发布容器运行时和镜像格式规范 V1.0  
http://www.linuxidc.com/Linux/2017-08/146286.htm  
[5] docker、oci、runc以及kubernetes梳理  
https://www.cnblogs.com/xuxinkun/p/8036832.html  
CoreOS VS Docker容器大战，之容器引擎  
http://www.youruncloud.com/blog/138.html  
OCI推出第1个Container技术映像档格式标准  
http://www.linuxidc.com/Linux/2016-05/131277.htm  
Containerd：一个控制runC的守护进程  
http://dockone.io/article/914  
Container runtime in Docker v1.11  
https://feisky.xyz/2016/04/28/Docker-1-11-Runtime/  
OCI 和 runc：容器标准化和 docker  
http://cizixs.com/2017/11/05/oci-and-runc  
