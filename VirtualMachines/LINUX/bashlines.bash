#GENERAL
ssh -i privatekey.pem user@hostname

#FIREWALL
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

#NGINX
sudo rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo yum install nginx
sudo systemctl start nginx.service
sudo systemctl status nginx.service