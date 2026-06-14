variable "aws_region" {
  default = "ap-northeast-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "my-key"
}

variable "db_password" {
  type        = string
  description = "Password for the RDS MySQL instance"
  sensitive   = true
}
