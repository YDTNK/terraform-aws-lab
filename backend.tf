terraform {
  backend "s3" {
    bucket         = "ydtnk-terraform-state-20260614"
    key            = "env/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
