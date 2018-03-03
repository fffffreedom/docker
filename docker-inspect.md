# docker inspect

`docker inspect`命令用来查看容器的详细信息，如果不加参数，会输出全部的信息。可以指定`-f`参数，使用`Go`的模版，以指定输出的信息。  

## 命令

普通输出：  
```
docker inspect -f container
```

json格式输出：  
```
docker inspect -f '{{json .State}}' container | jq .
```

## 用例

默认情况下，`docker inspect container`会输出所有的信息，要想输出指定的信息，可参见如下例子。

### 基础用例

根据`docker inspect`的输出，可以看到数据结构，通过`.`来一层一层的引用，见如下：  
```
docker inspect -f '{{json .Mounts}}' 12a170ba0a76 | jq .
docker inspect -f '{{json .State.Status}}' 12a170ba0a76 | jq .
```

或者可以使用`with`
```
docker inspect -f '{{.State.Status}}' 12a170ba0a76
docker inspect -f '{{with .State}} {{.Status}} {{end}}' 12a170ba0a76
```

### 高级用例

查看所有退出码不为0的容器：  
```
docker inspect -f '{{if ne 0.0 .State.ExitCode }}{{.Name}} {{.State.ExitCode}} {{end}}' $(docker ps -aq)
```

## 参考

奇妙的 Docker Inspect 模版  
http://88250.b3log.org/docker-inspect-template-magic-chinese  

go template package  
https://golang.org/pkg/text/template/  
