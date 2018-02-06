# 国内 docker 仓库镜像对比

> https://ieevee.com/tech/2016/09/28/docker-mirror.html  

首先，需要明确一个问题：Mirror 与 Private Registry 有什么区别？**二者有着本质的差别。**  

Private Registry 是开发者或者企业自建的镜像存储库，通常用来保存企业内部的 Docker 镜像，
用于内部开发流程和产品的发布、版本控制。 Mirror 是一种代理中转服务，我们(指daocloud)提供的 Mirror 服务，直接对接 Docker Hub 的官方 Registry。
Docker Hub 上有数以十万计的各类 Docker 镜像。 在使用 Private Registry 时，需要在 Docker Pull 或 Dockerfile 中直接
键入 Private Registry 的地址，通常这样会导致与 Private Registry 的绑定，缺乏灵活性。 
使用 Mirror 服务，只需要在 Docker 守护进程（Daemon）的配置文件中加入 Mirror 参数，即可在全局范围内透明的访问官方的 Docker Hub，
避免了对 Dockerfile 镜像引用来源的修改。  

简单来说，Mirror类似CDN，本质是官方的cache；Private Registry类似私服，跟官方没什么关系。
对我来说，由于我是要拖docker hub上的image，对应的是Mirror。 yum/apt的mirror又有点不一样，
它其实是把官方的库文件整个拖到自己的服务器上做镜像（不管有没有用），并定时与官方做同步；而Docker mirror只会缓存曾经使用过的image。  

## docker官方中国区mirror  
--registry-mirror=https://registry.docker-cn.com  
or 
```
# vim /etc/docker/daemon.json
{
        "registry-mirror":"https://registry.docker-cn.com"
}
```

推荐程度： ★★★★★  

## 网易163 docker镜像
```
$ sudo echo "DOCKER_OPTS=\"--registry-mirror=http://hub-mirror.c.163.com\"" >> /etc/default/docker
$ service docker restart
```
推荐程度： ★★★★★  


