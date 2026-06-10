resource "aws_instance" "nginx" {
  ami           = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  user_data = <<-EOT
#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

echo "Terraform Auto Nginx OK" > /usr/share/nginx/html/index.html
EOT

  tags = {
    Name = "terraform-nginx-auto"
  }
}
