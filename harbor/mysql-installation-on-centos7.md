# install mysql on centos 7.3 

> Reference: 
>
> https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html
> http://www.centoscn.com/mysql/2016/0315/6844.html

## Adding the MySQL Yum Repository

```shell
yum install -y wget
wget http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum localinstall -y mysql57-community-release-el7-11.noarch.rpm
```

> yum repolist enabled | grep "mysql.*-community.*"

## Selecting a Release Series

```shell
yum repolist all | grep mysql # 查看所有版本，enabled and disabled
```

##  Installing MySQL

```shell
yum install -y mysql-community-server 
```

## Starting the MySQL Server

```
systemctl enable mysqld
systemctl start mysqld
systemctl status mysqld
```
start会出错，无法正常启动mysqld：

```
mysqld_pre_systemd[7180]: Full path required for exclude: net:[4026532183].
```

需要修改SELinux的配置文件/etc/sysconfig/selinux：

```
SELINUX=permissive
```

