variable "db_subnet_group_name" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {}
variable "instance_class" {}

variable "username" {}
variable "password" {}

variable "vpc_id" {}
variable "app_sg_id" {}
