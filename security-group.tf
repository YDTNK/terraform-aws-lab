resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "allow http"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
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

  lifecycle {
    create_before_destroy = true

    # ★追加：ENI解放待ちハング対策
    prevent_destroy = false

  }
}

# ★追加（これが必要）
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "allow ssh and http"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "nginx-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "MySQL from EC2"

    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      aws_security_group.nginx_sg.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "rds-sg"
  }
}
