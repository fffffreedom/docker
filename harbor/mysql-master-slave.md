# ansible部署mysql(master and slave)

## files

部署之前，需要将配置文件、docker image文件拷贝到安装服务器！

```
- name: copy file
  copy: src={{ item.src }} dest={{ item.dest }}
  with_items:
   - src:
     dest:
   ......
```

## tasks/main.yml

### install mysql

需要用到mysql命令，故需要安装mysql:  
```
- name: install mysql local
  yum: name=/path/to/mysql57-community-release-el7-11.noarch.rpm state=present

- name: install mysql
  yum: name=mysql-community-server state=latest

- name: install MySQL-python
  yum: name=MySQL-python state=present
```

### modify mysql password
```
- lineinfile: dest=/path/to/mysql/conf/env regexp='^MYSQL_ROOT_PASSWORD=' line='MYSQL_ROOT_PASSWORD={{ mysql_pwd }}'
```

### install mysql master and slave

参见如下链接，其中有ansible部署主备mysql的脚本：  
> https://github.com/fffffreedom/ansible-playbooks

```
- name: run mysql container
  command: > 
    docker run -d --restart=always 
            -p 3306:3306 
            --name harbor-db
            -v /data/database:/var/lib/mysql 
            -v /deployment/harbor/mysql/conf.d:/etc/mysql/conf.d
            -v /deployment/harbor/mysql/sql:/sql
            --env-file=/deployment/harbor/mysql/conf/env 
            --log-driver=syslog 
            --log-opt tag=mysql 
            --log-opt syslog-address=tcp://127.0.0.1:514 
            vmware/harbor-db:dev

- name: Create the database users 
  mysql_user:
    login_host=127.0.0.1
    config_file=/etc/my.cnf
    login_user=root 
    login_password={{ mysql_pwd }}
    name={{ mysql_repl_name }}
    password={{ mysql_pwd }}
    priv='*.*:ALL'
    state=present
  register: result
  until: result | success
  retries: 5
  delay: 2

- name: Create the replication users
  mysql_user:
    login_host=127.0.0.1
    config_file=/etc/my.cnf
    login_user=root
    login_password={{ mysql_pwd }}
    name={{ mysql_repl_name }}
    host='%'
    password={{ mysql_pwd }}
    priv='*.*:REPLICATION SLAVE'
    state=present
  register: result
  until: result | success
  retries: 5
  delay: 2

- name: get the current master servers replication status
  mysql_replication:
    login_host=127.0.0.1
    config_file=/etc/my.cnf
    login_user=root
    login_password={{ mysql_pwd }}
    mode=getmaster
  delegate_to: "{{ mysql_master_ip }}"
  register: repl_stat
  when: mysql_repl_role == 'slave'

- name: Change the master in slave to start the replication
  mysql_replication:
    login_host=127.0.0.1
    config_file=/etc/my.cnf
    login_user=root
    login_password={{ mysql_pwd }}
    mode=changemaster
    master_host={{ mysql_master_ip }}
    master_log_file={{ repl_stat.File }}
    master_log_pos={{ repl_stat.Position }}
    master_user={{ mysql_repl_name }}
    master_password={{ mysql_pwd }}
  when: mysql_repl_role == 'slave'

- name: start slave in slave to start the replication
  mysql_replication:
    login_host=127.0.0.1
    config_file=/etc/my.cnf
    login_user=root
    login_password={{ mysql_pwd }}
    mode=startslave
  when: mysql_repl_role == 'slave'
```

## 主备mysql配置模板(templates)

主要备的id不能一致：  
```
[mysqld] 
log_bin = mysql-bin 
server-id = {{ mysql_db_id }} 
```
