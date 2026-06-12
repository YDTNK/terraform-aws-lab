variable "alb_name" {}
variable "tg_name" {}

variable "vpc_id" {}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ami_id" {}
variable "instance_type" {}

variable "user_data" {}
