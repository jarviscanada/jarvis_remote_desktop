#!/bin/bash

#instasll docker
sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum -y install docker-ce docker-ce-cli containerd.io

#auto start
#sudo systemctl enable docker
#start service
sudo systemctl start docker
sudo docker -v

#allow centos user to run docker without sudo
sudo groupadd docker
sudo usermod -aG docker centos
#must logout session
exit

#auto start docker
#systemctl enable docker

#start docker
systemctl start docker
#systemctl start|status|restart docker


