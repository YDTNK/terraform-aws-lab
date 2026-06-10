provider "aws" {
  region = "ap-northeast-1"
}

# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc"
  }
}

# ----------------------------
# Internet Gateway
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-igw"
  }
}

# ----------------------------
# ALB
# ----------------------------
resource "aws_lb" "alb" {
  name               = "nginx-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_b.id
  ]
}

# ----------------------------
# Public Subnet
# ----------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

# ----------------------------
# Route Table
# ----------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# ----------------------------
# ALB Security Group
# ----------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# ----------------------------
# Security Group（EC2）
# ----------------------------
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Managed by Terraform" # ← 変更しない
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg"
  }

  # 重要：不要な差分暴れ防止
  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------
# EC2 Instance
# ----------------------------
resource "aws_instance" "nginx" {
  ami           = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  key_name = "my-key"

  user_data = <<-EOF
#!/bin/bash
set -eux

# update
yum update -y

# nginx install
amazon-linux-extras enable nginx1
yum clean metadata
yum install -y nginx

# start nginx
systemctl enable nginx
systemctl start nginx

# test page
echo "Terraform Auto Nginx OK" > /usr/share/nginx/html/index.html
EOF

  tags = {
    Name = "terraform-nginx-auto"
  }

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }
}

# ----------------------------
# Target Group
# ----------------------------
resource "aws_lb_target_group" "tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

# ----------------------------
# EC2をTargetに登録
# ----------------------------
resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}


# ----------------------------
# Listener
# ----------------------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ----------------------------
# Output
# ----------------------------
output "public_ip" {
  value = aws_instance.nginx.public_ip
}
