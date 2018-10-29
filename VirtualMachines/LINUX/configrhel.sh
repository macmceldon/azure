#!/bin/sh
sudo yum -y install httpd
#FIREWALL
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload

sudo apachectl start