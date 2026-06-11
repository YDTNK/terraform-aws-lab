resource "aws_instance" "nginx" {
  ami           = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  subnet_id              = module.vpc.public_subnet_a_id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = aws_key_pair.this.key_name

  # ★重要：インスタンス差し替え抑制
  lifecycle {
    ignore_changes = [
      subnet_id,
      vpc_security_group_ids,
    ]

    # ★追加：destroy順序安定化
    create_before_destroy = false

  }

  user_data = <<EOF
#!/bin/bash
yum update -y
amazon-linux-extras enable nginx1
yum install -y nginx
systemctl start nginx
systemctl enable nginx

echo "Terraform nginx OK" > /usr/share/nginx/html/index.html
EOF

  tags = {
    Name = "terraform-nginx"
  }
}

resource "aws_key_pair" "this" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/terraform-key.pub")
}
