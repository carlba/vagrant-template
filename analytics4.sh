#!/bin/bash

filename="analytics4-feature.ANFO-147.latest.tgz"
uri="http://releases.birdstep.internal/auto/ANFO-ANFO/$filename"
epel="true"
remi="false"

current_dir=$PWD
tmp_dir=$(mktemp -d)

cd $tmp_dir
yum install -y git

git clone https://github.com/carlba/linux_install

[[ "$epel" == "true" ]] && linux_install/centos/epel.sh
[[ "$remi" == "true" ]] && linux_install/centos/remi.sh
linux_install/centos/redis.sh
linux_install/centos/elasticsearch.sh
linux_install/centos/kibana.sh

sudo chkconfig --add redis
systemctl enable redis

sudo chkconfig --add elasticsearch
systemctl enable elasticsearch

sudo chkconfig --add kibana
systemctl enable kibana

# Installing dependencies
yum -y install openssl-devel python-virtualenv python-devel make gcc libffi-devel

# Installing analytics4
wget "$uri"
extracted_folder=$(tar tf $filename | basename $(head -n1))

tar -xzf $filename
$extracted_folder/install

# Autostarting the analytics4 services is currently not working. 
# systemctl enable analytics4-frontend
# systemctl enable analytics4-backend

#Disable iptables (This should only ever be done in a test environment)
#sudo chkconfig iptables off

# Cleaning up after installation
rm -rf $tmp_dir

