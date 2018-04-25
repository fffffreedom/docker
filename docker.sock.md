# [关于/var/run/docker.sock](https://blog.fundebug.com/2017/04/17/about-docker-sock/)

`docker.sock` 是Docker守护进程(Docker daemon)默认监听的Unix域套接字(Unix domain socket)，容器中的进程可以通过它与Docker守护进程进行通信。

## 用途举例

### 1. [Portainer](http://portainer.io/)

不妨看一下 Portainer，它提供了图形化界面用于管理Docker主机和Swarm集群。
**如果使用Portainer管理本地Docker主机的话，需要绑定/var/run/docker.sock：**  

```
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
```

访问9000端口可以查看图形化界面，可以管理容器(container)，镜像(image)，数据卷(volume)

Portainer 通过绑定的/var/run/docker.sock文件与Docker守护进程通信，执行各种管理操作。
