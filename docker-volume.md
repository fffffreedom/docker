# docker-volume
## volume basic
## volume practise
在v1.10.0版本之后，如果在挂载volume到容器时，指定了volume名，即-v name:/container/dir,  
即使docker run指定了--rm标志，在容器退出时，也不会删除该volume。  
https://github.com/moby/moby/pull/19568
