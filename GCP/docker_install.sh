#!/bin/bash

yum -y install docker
groupadd docker
usermod -aG docker centos
#must reboot
reboot
#systemctl start docker

