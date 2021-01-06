#!/bin/bash
yum install httpd -y
chkconfig httpd on
service httpd start
echo "<h1> Java Home App</h1>" > /var/www/html/index.html