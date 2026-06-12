output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "private_subnet_a_id" {
  value = module.vpc.private_subnet_a_id
}

output "private_subnet_c_id" {
  value = module.vpc.private_subnet_c_id
}
