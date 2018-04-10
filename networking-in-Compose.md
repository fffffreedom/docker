# Networking in Compose

默认情况下，compose会为你的服务或者应用创建一个网络，服务中所有容器会加入这个默认网络，并可以通过这个网络相互访问。

举个例子，在myapp目录下有如下docker-compose.yml文件：

```yaml
version: "3"
services:
  web:
    build: .
    ports:
      - "8000:8000"
  db:
    image: postgres
    ports:
      - "8001:5432"
```

当你运行`docker-compose up` 时，会发生以事情：

* 创建名为myapp_default的网络；
* 根据dockerfile创建web容器，它会用web的名字加入myapp_default网络；
* 使用postgres镜像创建db容器，它会使用db的名字加入myapp_default网络。

之后，所有容器能够查找到web和db容器名，并获取到合适的ip地址。例如，web容器中的应用程序就可以通过URL `postgres://db:5432` 来使用postgres数据库。

区别`HOST_PORT`和`CONTAINER_PORT`非常重要。在上面的例子中，对于db容器来说，`HOST_PORT`是8001，`CONTAINER_PORT`是5432。网络化的服务到服务间的通信网络使用的是`CONTAINER_PORT`。当定义了`HOST_PORT`，该服务也可以被集群外的应用访问。

从上面可知，网络的默认名字是由运行`docker-compose up`命令所在的目录名加上`_default`后缀。我们可以通过以下两种方式指定网络名：

*  在docker-compose命令行中指定`--project-num`参数
*  设置`COMPOSE_PROJECT_NAME`环境变量

**在web容器中，你可以通过`postgres://db:5432` 来连接到db容器，而运行窗口的主机中，需要通过`postgres://{DOCKER_IP}:8001`来访问。**

# top-level networks

顶层networks关键字可以让你指定将要创建的网络。应用可以使用次层的networks关键字，来指定使用顶层已经创建好的网络。

## driver

`driver`指定了网络所要使用的驱动。默认的驱动由正在使用的Docker Engine的配置决定，在大多数情况下，单主机使用`bridge`，swarm中使用`overlay`。

## driver_opts

指定一系列选项传给网络驱动的key-value对，这些选项是依赖于驱动的。从驱动的文档中去查询更多信息。该属性是可选的。

```yaml
  driver_opts:
    foo: "bar"
    baz: 1
```

## enable_ipv6

使能网络的ipv6网络功能。

## ipam

IP Address Management. 指定用户的IPAM配置。它是具有几个属性的对象，但都是可选的：

* driver: 指定用户IPAM驱动，替代默认的default
* config: 一个或多个配置块，每个块包含如下关键字：
  * subnet: CIDR格式的子网络，代表一个网络段

```yaml
ipam:
  driver: default
  config:
    - subnet: 172.28.0.0/16
```

>  Additional IPAM configurations, such as `gateway`, are only honored for version 2 at the moment.

## internal

默认情况下，通过接入bridge，Docker提供了外部可连接性。如果你想创建一个外部隔离的overlay网络，只要指定`internal`属性为true。

## labels

可以使用数组或字典格式的**Docker labels**给容器添加元数据。推使用**reverse-DNS**标记法来防止标签和其软件冲突。

```yaml
labels:
  com.example.description: "Financial transaction network"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""

labels:
  - "com.example.description=Financial transaction network"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

 ## external

如果external指定为true，表示网络是在compose外创建的。docker-compose up将不再尝试去创建网络，如果网络不存在，将会产生错误。

**external不能和其它网络配置关键字（driver, driver_opts, ipam, internal）一起使用！**

下面的例子中，proxy是通向外网的网关。compose不会去创建一个叫[projectname]_outside的网络，崦是会查找一个已经存在的名为outside的网络，并将proxy服务容器连接到该网络，

```yaml
version: '2'

services:
  proxy:
    build: ./proxy
    networks:
      - outside
      - default
  app:
    build: ./app
    networks:
      - default

networks:
  outside:
    external: true
```

也可以在compose file中指定单独指定要被引用的网络的名称：

```yaml
networks:
  outside:
    external:
      name: actual-name-of-network
```

# specifying custom networks

除了使用默认的网络，你可以使用顶层的`networks`关键字来指定自己定制的网络，也就可以连接到外部创建的不由compose控制的网络了！

举个例子，有个如下compose file，它定义了两个网络：`frontend`和`backend`。proxy服务和db服务没有共享一个网络，所以它们两是隔离的。而app服务可以和两者通信，因为连接到的两个网络中。

```yaml
version: "3"
services:
  proxy:
    build: ./proxy
    networks:
      - frontend
  app:
    build: ./app
    networks:
      - frontend
      - backend
  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    # Use a custom driver
    driver: custom-driver-1
  backend:
    # Use a custom driver which takes special options
    driver: custom-driver-2
    driver_opts:
      foo: "1"
      bar: "2"
```

# configuring the default network

除了指定自己定制的网络，你还可以通过在顶层networks下指定**default**属性，来改变整个应用范围的网络配置。

```yaml
version: "3"
services:

  web:
    build: .
    ports:
      - "8000:8000"
  db:
    image: postgres

networks:
  default:
    # Use a custom driver
    driver: custom-driver-1
```

# using a pre-existing network

如果你想把你的容器加入到一个已有的网络中，可以使用`external`选项：

```yaml
networks:
  default:
    external:
      name: my-pre-existing-network
```

compose会查找名为`my-pre-existing-network`的网络，并将你的应用容器连接到该网络，compose并不会去尝试创建名为`[projectname]_default`的网络。

# reference

https://docs.docker.com/compose/networking/  
https://docs.docker.com/compose/compose-file/#network-configuration-reference  
