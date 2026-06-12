#!/bin/bash
set -eux

yum update -y
amazon-linux-extras enable nginx1
yum install -y nginx

systemctl enable nginx
systemctl start nginx

echo "OK" > /usr/share/nginx/html/index.html
echo "OK" > /usr/share/nginx/html/health

chown nginx:nginx /usr/share/nginx/html/*
chmod 644 /usr/share/nginx/html/*
