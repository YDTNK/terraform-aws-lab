resource "aws_launch_template" "nginx" {
  name_prefix   = "nginx-lt-"
  image_id      = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.nginx_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
set -eux

yum update -y
amazon-linux-extras enable nginx1
yum clean metadata
yum install -y nginx

systemctl enable nginx
systemctl start nginx

# 初期待機（軽いバッファ）
sleep 5

# 起動確認（本番ロジック）
for i in {1..30}; do
  curl -s http://localhost/health && break
  sleep 2
done

# ALBヘルスチェック用エンドポイント
echo "OK" > /usr/share/nginx/html/index.html
echo "OK" > /usr/share/nginx/html/health

chown nginx:nginx /usr/share/nginx/html/*
chmod 644 /usr/share/nginx/html/*

EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform-nginx-lt"
    }
  }
}
