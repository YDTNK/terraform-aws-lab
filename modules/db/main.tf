resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier     = var.db_name
  engine         = "mysql"
  instance_class = var.instance_class

  allocated_storage = 20 # ★これ必須（最低でも20GB推奨）


  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az            = true
  publicly_accessible = false
  skip_final_snapshot = true
}
