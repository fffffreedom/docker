# enable docker daemon debug
https://success.docker.com/article/How_do_I_enable_'debug'_logging_of_the_Docker_daemon  
```
vim /etc/docker/daemon.json
{
    "debug": true
}
systemctl restart docker
```
