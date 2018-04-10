#!/bin/bash
# set -x 
# harbor install script on signle host.

# specification:
# 1. none

# usage:
# install-harbor-on-single-host.sh -p ip[:port] [-h harbor_pwd] [-m mysql_password]

# History 
# v1.0 juruqiang, 2017-08-04

usage() {
    echo "Usage:"
    echo "$0 -m ip[:port] [-b harbor_pwd] [-p mysql_pwd]"
    echo "$0 --master ip[:port] [--harbor_pwd harbor_pwd] [--mysql_pwd mysql_pwd]"
    exit 1
}

[ $# -eq 0 ] && usage

ARGS=`getopt -a -o m:b:p:h -l master:,harbor_pwd:,mysql_pwd:,help -- "$@"`
eval set -- "${ARGS}" 

while true
do  
        case "$1" in  
        -m|--master) MASTER=$2; shift;;
        -b|--harbor_pwd) HARBOR_PWD=$2; shift;;
        -p|--mysql_pwd) MYSQL_PWD=$2; shift;;
        -h|--help) usage;;
        --)shift; break;;
        esac
shift
done

echo ${MASTER}
echo ${HARBOR_PWD}
echo ${MYSQL_PWD}


port=`echo ${MASTER} | awk -F':' '{print $2}'`

# docker daemon config
#cat >/etc/docker/daemon.json<<EOF
#{
#    "insecure-registry": ["${MASTER}"]
#}
#EOF

#mkdir -p /etc/systemd/system/docker.service.d/
#cat >/etc/systemd/system/docker.service.d/docker.conf<<EOF
#[Service]
#ExecStart=
#ExecStart=/usr/bin/dockerd --insecure-registry ${MASTER}
#EOF

#systemctl daemon-reload
#systemctl enable docker
#systemctl restart docker

# docker-compose for managing harbor
chmod +x docker-compose
cp docker-compose /usr/local/bin/

mount /tmp -o remount,exec 

echo "delet old files..."
rm -rf /root/harbor
rm -rf /data

# harbor deploy
tar xzvf harbor-offline-installer-v1.1.2.tgz -C /root/
cd /root/harbor

echo "modify harbor config..."
sed -i 's/^hostname = .*$/hostname = '${MASTER}'/' harbor.cfg

if [ -n "${port}" ]; then
	sed -i 's/80:80/'${port}':80/' docker-compose.yml
fi
if [ -n "${HARBOR_PWD}" ]; then
	sed -i 's/^harbor_admin_password.*/harbor_admin_password = '${HARBOR_PWD}'/' harbor.cfg
fi
if [ -n "${HARBOR_PWD}" ]; then
	sed -i 's/^db_password.*/db_password = '${MYSQL_PWD}'/' harbor.cfg
fi

sed -i 's/^verify_remote_cert.*/verify_remote_cert = off/' harbor.cfg

echo "install and start harbor..."
sh install.sh

