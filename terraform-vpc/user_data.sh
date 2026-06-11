#!/bin/bash
yum update -y

amazon-linux-extras install nginx1 -y

systemctl enable nginx
systemctl start nginx

echo "Terraform NEW VPC OK" > /usr/share/nginx/html/index.html
