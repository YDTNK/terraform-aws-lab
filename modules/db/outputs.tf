output "db_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
