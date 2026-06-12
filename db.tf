resource "aws_db_subnet_group" "db" {
  name = "terraform-db-subnet-group"

  subnet_ids = [
    module.vpc.private_subnet_a_id,
    module.vpc.private_subnet_c_id
  ]

  tags = {
    Name = "terraform-db-subnet-group"
  }
}
