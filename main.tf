module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
  name       = "terraform-vpc"
  region     = "ap-northeast-1"

  public_subnet_a = "10.0.1.0/24"
  public_subnet_c = "10.0.2.0/24"
}

module "app" {
  source = "./modules/app"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_name = "terraform-alb"
  tg_name  = "terraform-tg"

  ami_id        = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"

  user_data = file("user_data.sh")
}

module "db" {
  source = "./modules/db"

  db_subnet_group_name = "terraform-db-subnet-group"

  db_subnet_ids = concat(
    module.vpc.private_subnet_ids,
    module.vpc.db_subnet_ids
  )

  db_name        = "terraform-mysql"
  instance_class = "db.t3.micro"

  username = "admin"
  password = var.db_password

  vpc_id    = module.vpc.vpc_id
  app_sg_id = module.app.nginx_sg_id
}
