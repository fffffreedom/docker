# docker-volume
http://dockone.io/article/128  
http://dockone.io/article/129  
## volume basic
想要了解Docker Volume，首先我们需要知道Docker的文件系统是如何工作的。  
Docker镜像是由多个文件系统（只读层）叠加而成。当我们启动一个容器的时候，Docker会加载只读镜像层并在其上（译者注：镜像栈顶部）添加一个读写层。如果运行中的容器修改了现有的一个已经存在的文件，那该文件将会从读写层下面的只读层复制到读写层，该文件的只读版本仍然存在，只是已经被读写层中该文件的副本所隐藏。当删除Docker容器，并通过该镜像重新启动时，之前的更改将会丢失。在Docker中，只读层及在顶部的读写层的组合被称为Union File System（联合文件系统）。 
为了能够保存（持久化）数据以及共享容器间的数据，Docker提出了Volume的概念。简单来说，Volume就是目录或者文件，它可以绕过默认的联合文件系统，而以正常的文件或者目录的形式存在于宿主机上。  
Volume可以用来持久化数据，将数据和容器分离，做数据备份，也可以在多个容器之间共享！  
## volume command
|Command|Description|
|:-------|:----------|
|docker volume create|Create a volume |
|docker volume inspect|Display detailed information on one or more volumes|
|docker volume ls|List volumes|
|docker volume prune|Remove all unused volumes|
|docker volume rm|Remove one or more volumes|
## volume初始化or声明
我们可以通过两种方式来初始化Volume：
- 运行docker run -v命令声明Volume（可以指定主机上的具体目录或文件）
```
man docker run
docker run [-v|--volume[=[[HOST-DIR:]CONTAINER-DIR[:OPTIONS]]]] ......
```
从上面可知，HOST-DIR是可以省略的，它可以是**文件或者目录**；如果省略，则docker会在主机的目录（/var/lib/docker/volumes/)下创建一个临时的目录，并将其挂载到容器。  
```
# docker run --rm -it --name container-test -v /data busybox /bin/sh
/ # ls /data
/ #
```
上面的命令会生成一个随机的volume，并挂载到容器的/data目录下，它绕过联合文件系统，我们可以在主机上直接操作该目录。任何在该镜像/data路径的文件将会被复制到Volume。我们可以通过下面的命令查看挂载到容器的volume对应的主机目录路径：
```
# docker inspect -f {{.Mounts}} container-test
[{dffd4eda5cd05131824cd99efea48c47fcb0489a169d4e12c8bf399a3f00fc57 /var/lib/docker/volumes/dffd4eda5cd05131824cd99efea48c47fcb0489a169d4e12c8bf399a3f00fc57/_data /data local  true }]
```
从输出可见，docker会在主机中创建一个临时目录，并将其挂载到了容器：  
`/var/lib/docker/volumes/dffd4eda5cd05131824cd99efea48c47fcb0489a169d4e12c8bf399a3f00fc57/_data`  
我们在主机的目录中创建一个文件：  
```
# touch /var/lib/docker/volumes/dffd4eda5cd05131824cd99efea48c47fcb0489a169d4e12c8bf399a3f00fc57/_data/host-to-container
```
然后在容器中查看：
```
/ # ls /data
host-to-container
```
可见主机和容器的目录是同步的。在指定了主机volome目录时，docker会把直接挂载到容器中：  
```
# docker run --rm -it --name container-test -v /data:/data busybox /bin/sh
/ # ls /data
ca_download  config       database     job_logs     psc          registry     secretkey
```
- 在Dockerfile中通过使用VOLUME指令声明Volume(无法指定主机上的目录)
```
# cat Dockerfile
FROM busybox
VOLUME /data

# docker build -t freedom/busybox:v1 .
Sending build context to Docker daemon 2.048 kB
Step 1 : FROM busybox
 ---> 6ad733544a63
Step 2 : VOLUME /data
 ---> Running in 10fc5a8bdcf4
 ---> a5fce3cdf00f
Removing intermediate container 10fc5a8bdcf4

# docker run -it freedom/busybox:v1 /bin/sh
/ # ls /data
/ # 

# docker inspect -f {{.Mounts}} 36f41025de1c
[{9e34c16e1db8420b72987a83d89b975839c504f03b64b912d86e7d44d77ec34d /var/lib/docker/volumes/9e34c16e1db8420b72987a83d89b975839c504f03b64b912d86e7d44d77ec34d/_data /data local  true }]
```
## volume共享
如果要授权一个容器访问另一个容器的Volume，我们可以使用--volumes-from参数来执行docker run。
```
# docker run --rm -it --name container-data  -v /data busybox /bin/sh
/ # ls /data
/ # 
/ # touch /data/create-from-data
# docker run --rm -it --name container-app --volumes-from container-data busybox /bin/sh
/ # ls /data
/ # 
/ # ls /data/
create-from-data
```
在data容器里创建了一个文件，在app容器里就可以立即看到！  
## 数据容器

## volume删除
在v1.10.0版本之后，如果在挂载volume到容器时，指定了volume名，即-v /host/dir-or-file:/container/dir, 即使docker run指定了--rm标志，在容器退出时，也不会删除该volume。  
https://github.com/moby/moby/pull/19568
