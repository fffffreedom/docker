# mysql ops

## login
```
mysql -h 127.0.0.1 -u root -p
```

## ops
```
show databases;
use registry;
show tables;
select * from repository;
delete from repository where repository_id=XX;
```

## master/slave
```
172.25.34.107 master
CREATE USER 'repl'@'172.25.34.108' IDENTIFIED BY 'Harbor12345';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'172.25.34.108';
show master status;
show grants for 'repl'@'172.25.34.108'

172.25.34.108 slave
change master to master_host='172.25.34.107',master_user='repl',master_password='Harbor12345',master_log_file='mysql-bin.000003',master_log_pos=8665;
start slave;
show slave status\G;
```
