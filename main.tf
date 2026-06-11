module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
  name       = "terraform-vpc"
  region     = "ap-northeast-1"

  public_subnet_a = "10.0.1.0/24"
  public_subnet_c = "10.0.2.0/24"
}
