resource "aws_db_instance" "mysql" {
  identifier = "terraform-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = "ChangeMe12345!"

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az = true

  skip_final_snapshot = true

  publicly_accessible = false
}
