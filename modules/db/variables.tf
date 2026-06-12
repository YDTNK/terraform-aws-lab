variable "db_subnet_group_name" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {}
variable "instance_class" {}

variable "username" {}
variable "password" {}

variable "rds_sg_id" {}
