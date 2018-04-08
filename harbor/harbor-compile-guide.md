# harbor代码开发

> https://github.com/vmware/harbor/blob/v1.1.2/docs/compile_guide.md

## Step 1: Prepare for a build environment for Harbor

|Software|Required Version|
|:--|:--|
|docker|1.12.0 +|
|docker-compose|1.11.0 +|
|python|2.7 +|
|git|1.9.1 +|
|make|3.81 +|
|golang*|1.7.3 +|
|*optional, required only if you use your own Golang environment.	||

## Step 2: Getting the source code

下载源码：  
```
git clone https://github.com/vmware/harbor
```

切换到开发分支：  
```
# 查看tag
git tag -l
# 切换到指定的tag
git checkout -b branch_name tag_name
eg:
git checkout -b v112 v1.1.2
```

## Step 3: modify the source code

在调试的时候需要看日志，但由于harbor是会把日志全部导到`harbor-log`容器中，存在延时，不方便调试，我们可以修改容器的日志采集方法，
将`make/docker-compose.yml`中的logging配置去掉，然后使用docker logs -f harbor-ui命令查看实时的日志！  

## Step 3: Building and installing Harbor

### Configuration

Edit the file `make/harbor.cfg` and make necessary configuration changes such as hostname, admin password and mail server.

### Compiling and Running

- 提前pull需要用到的image  
```
docker pull golang:1.7.3 
docker pull vmware/harbor-clarity-ui-builder:0.8.4
```

- 完全编译  
```
make install GOBUILDIMAGE=golang:1.7.3 COMPILETAG=compile_golangimage CLARITYIMAGE=vmware/harbor-clarity-ui-builder:0.8.4
```

- 编译单个镜像  
```
#!/bin/sh

# 只改了ui的代码，可以只编译ui
make compile_ui GOBUILDIMAGE=golang:1.7.3 COMPILETAG=compile_golangimage CLARITYIMAGE=vmware/harbor-clarity-ui-builder:0.8.4
if [ $? -ne 0 ]
then
    exit 1
fi

make build GOBUILDIMAGE=golang:1.7.3 COMPILETAG=compile_golangimage CLARITYIMAGE=vmware/harbor-clarity-ui-builder:0.8.4
if [ $? -ne 0 ]
then
    exit 1
fi

# 启动harbor
cd make
docker-compose up -d
```

- 保存镜像  
```
docker save -o harbor-jobservice-v1.1.2-dev.tar vmware/harbor-jobserivce:dev
docker save -o harbor-ui-v1.1.2-dev.tar vmware/harbor-ui:dev
```
