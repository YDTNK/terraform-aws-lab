output "vpc_id" {
  value = aws_vpc.this.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_c_id" {
  value = aws_subnet.public_c.id
}
