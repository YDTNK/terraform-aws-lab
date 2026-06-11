#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
echo "Terraform Auto Nginx OK" > /usr/share/nginx/html/index.html
