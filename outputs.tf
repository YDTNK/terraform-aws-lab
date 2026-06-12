output "alb_dns" {
  value = module.app.alb_dns
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "db_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_instance_id" {
  value = module.db.db_instance_id
}

output "rds_sg_id" {
  value = module.db.rds_sg_id
}
