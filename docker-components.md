# docker组件浅析
从Docker 1.11之后，Docker Daemon被分成了多个模块以适应**OCI**标准。拆分之后，结构分成了以下几个部分：  
![](https://github.com/fffffreedom/Pictures/blob/master/docker-arch.png)  
其中，containerd独立负责容器运行时和生命周期（如创建、启动、停止、中止、信号处理、删除等），
其他一些如镜像构建、卷管理、日志等由Docker Daemon的其他模块处理。docker engine和Docker Daemon的关系如下图：  
![](https://github.com/fffffreedom/Pictures/blob/master/docker-engine.jpg)  
## docker组件
docker组件包括如下几个部分：　　
- docker  
docker命令行工具，是docker的客户端。  
- dockerd  
docker daemon，是docker的服务端。从上面的图可知道，docker client通过调用RESTful API与其通信。  
作为Docker容器管理的守护进程，Docker Daemon从最初集成在docker命令中（1.11版本前），到后来的独立成单独二进制程序（1.11版本开始），
其功能正在逐渐拆分细化，被分配到各个单独的模块中去。  
- docker-containerd  
containerd是容器技术标准化之后的产物，为了能够兼容OCI标准，将容器运行时及其管理功能从Docker Daemon剥离。
理论上，即使不运行dockerd，也能够直接通过containerd来管理容器。
（当然，containerd本身也只是一个守护进程，容器的实际运行时由后面介绍的runC控制。）  
containerd的组成如下：  
![](https://github.com/fffffreedom/Pictures/blob/master/containerd.png)
> https://github.com/containerd/containerd  

containerd向上为Docker Daemon提供了gRPC接口，使得Docker Daemon屏蔽下面的结构变化，确保原有接口向下兼容。
向下通过containerd-shim结合runC，使得引擎可以独立升级，避免之前Docker Daemon升级会导致所有容器不可用的问题。  
Docker、containerd和containerd-shim之间的关系，可以通过启动一个Docker容器，观察进程之间的关联。首先启动一个容器：  
`docker run -d busybox sleep 60`  
然后通过pstree命令查看进程之间的父子关系：  
```
# 查看docker相关进程，从下面可以看出，有3个docker相关的进程正在运行。
# 第一个docker daemon
# 第二个是docker-containerd
# 第三个是docker-containerd-shim
[root@localhost ~]# ps aux | grep docker
root       975  0.0  0.7 704208 28984 ?        Ssl  08:55   0:01 /usr/bin/dockerd
root      1083  0.0  0.1 289808  6928 ?        Ssl  08:55   0:00 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc
root      1589  0.0  0.1 272828  4156 ?        Sl   09:33   0:00 docker-containerd-shim 67925c740ee2c043597d5aa0fedc284e7250d0235344fa50e8db9bc308da272f /var/run/docker/libcontainerd/67925c740ee2c043597d5aa0fedc284e7250d0235344fa50e8db9bc308da272f docker-runc
root      1625  0.0  0.0 112652   948 pts/0    S+   09:33   0:00 grep --color=auto docker
[root@localhost ~]# pstree -l -a -A 975
dockerd
  |-docker-containe -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc
  |   |-docker-containe 67925c740ee2c043597d5aa0fedc284e7250d0235344fa50e8db9bc308da272f /var/run/docker/libcontainerd/67925c740ee2c043597d5aa0fedc284e7250d0235344fa50e8db9bc308da272f docker-runc
  |   |   |-sleep 60
  |   |   `-8*[{docker-containe}]
  |   `-9*[{docker-containe}]
  `-9*[{dockerd}]
```  
当Docker daemon启动之后，dockerd和docker-containerd进程一直存在。当启动容器之后，docker-containerd进程（也是这里介绍的containerd组件）
会创建docker-containerd-shim进程，其中的参数`67925c740ee2c043597d5aa0fedc284e7250d0235344fa50e8db9bc308da272f`就是要启动容器的id。
最后docker-containerd-shim子进程，已经是实际在容器中运行的进程（既sleep 60）。  
docker-containerd-shim另一个参数，是一个和容器相关的目录：  
`/var/run/docker/libcontainerd/67925c740ee2c043597d5aa0fedc284e7250d0235344fa50e8db9bc308da272f`  
里面的内容有：  
```
-rw-r--r--. 1 root root 18320 Jan 24 09:52 config.json
prwx------. 1 root root     0 Jan 24 09:52 init-stderr
prwx------. 1 root root     0 Jan 24 09:52 init-stdin
prwx------. 1 root root     0 Jan 24 09:52 init-stdout
```
其中包括了**容器配置**和标准输入、标准输出、标准错误三个管道文件。  
- docker-containerd-shim  
从上面的实践可知，docker-containerd-shim是用来管理容器的，它接收三个参数：
  - 容器id
  - boundle目录（containerd的对应某个容器生成的目录，一般位于：/var/run/docker/libcontainerd/containerID）
  - 容器运行时工具（docker-runc）
是它通过运行时工具来管理容器的，也就是这里的docker-runc。  
- docker-runc  
OCI定义了容器运行时标准，runC是Docker按照开放容器格式标准（OCF, Open Container Format）制定的一种具体实现。  
runC是从Docker的libcontainer中迁移而来的，实现了容器启停、资源隔离等功能。
**Docker默认提供了docker-runc实现**，事实上，通过containerd的封装，可以在Docker Daemon启动的时候指定runc的实现。  
我们可以通过启动Docker Daemon时增加--add-runtime参数来选择其他的runC现。例如：  
`docker daemon --add-runtime "custom=/usr/local/bin/my-runc-replacement"`    
需要指出的是，我们可以不使用Docker Daemon直接启动一个镜像！具体过程可参见参考[1]。  
- docker-containerd-ctr  
```
[root@localhost ~]# docker-containerd-ctr -h
NAME:
   ctr - High performance container daemon cli

USAGE:
   docker-containerd-ctr [global options] command [command options] [arguments...]
   
VERSION:
   0.2.4 commit: 2a5e70cbf65457815ee76b7e5dd2a01292d9eca8
   
COMMANDS:
   checkpoints	list all checkpoints
   containers	interact with running containers
   events	receive events from the containerd daemon
   state	get a raw dump of the containerd state
   version	return the daemon version
   help, h	Shows a list of commands or help for one command
   
GLOBAL OPTIONS:
   --debug						enable debug output in the logs
   --address "unix:///run/containerd/containerd.sock"	proto://address of GRPC API
   --conn-timeout "1s"					GRPC connection timeout
   --help, -h						show help
   --version, -v					print the version
```
- docker-proxy  
docker-proxy是用来管理端口映射的。我们起动一个registry容器看下：  
```
[root@localhost ~]# docker run -d -it -p 5000:5000 --name myregistry registry
[root@localhost ~]# netstat -anp | grep 5000
tcp6       0      0 :::5000                 :::*                    LISTEN      2143/docker-proxy
[root@localhost ~]# docker port myregistry
5000/tcp -> 0.0.0.0:5000
```
## 命令help
```
[root@localhost ~]# docker-containerd -h
NAME:
   containerd - High performance container daemon

USAGE:
   docker-containerd [global options] command [command options] [arguments...]
   
VERSION:
   0.2.4 commit: 2a5e70cbf65457815ee76b7e5dd2a01292d9eca8
   
COMMANDS:
   help, h	Shows a list of commands or help for one command
   
GLOBAL OPTIONS:
   --debug							enable debug output in the logs
   --state-dir "/run/containerd"				runtime state directory
   --metrics-interval "5m0s"					interval for flushing metrics to the store
   --listen, -l "unix:///run/containerd/containerd.sock"	proto://address on which the GRPC API will listen
   --runtime, -r "runc"						name or path of the OCI compliant runtime to use when executing containers
   --runtime-args [--runtime-args option --runtime-args option]	specify additional runtime args
   --shim "containerd-shim"					Name or path of shim
   --pprof-address 						http address to listen for pprof events
   --start-timeout "15s"					timeout duration for waiting on a container to start before it is killed
   --retain-count "500"						number of past events to keep in the event log
   --graphite-address 						Address of graphite server
   --help, -h							show help
   --version, -v						print the version
[root@localhost ~]# docker-proxy -h
Usage of docker-proxy:
  -container-ip string
    	container ip
  -container-port int
    	container port (default -1)
  -host-ip string
    	host ip
  -host-port int
    	host port (default -1)
  -proto string
    	proxy protocol (default "tcp")
```
## reference
[1] Docker、Containerd、RunC...：你应该知道的所有  
http://www.infoq.com/cn/news/2017/02/Docker-Containerd-RunC  
https://www.cnblogs.com/zhxshseu/p/a647de7065d3c19433c07b9355e50cd6.html  
http://blog.csdn.net/u013812710/article/details/79001463  
Docker 架构之Daemon  
http://blog.csdn.net/afandaafandaafanda/article/details/48649239  
理解容器端口映射  
http://tonybai.com/2016/01/18/understanding-binding-docker-container-ports-to-host/
