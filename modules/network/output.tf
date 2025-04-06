output "bastion_sg" {
  value = aws_security_group.three_tier_bastion_sg.id
}


output "vpc_id" {
  value = aws_vpc.three_tier_vpc.id
}

output "public_subnets" {
  value = aws_subnet.three_tier_public_subnets.*.id
}

output "frontend_sg" {
  value = aws_security_group.three_tier_frontend_sg.id
}

output "private_frontend_subnets" {
  value = aws_subnet.three_tier_private_frontend_subnets.*.id
}
output "private_backend_subnets" {
  value = aws_subnet.three_tier_private_backend_subnets.*.id
}

output "backend_sg" {
  value = aws_security_group.three_tier_backend_sg.id
}

output "lb_sg" {
  value = aws_security_group.three_tier_loadbalancer_sg.id
}

output "private_subnets_db" {
  value = aws_subnet.three_tier_private_subnets_db.*.id
}

output "db_sg" {
  value = aws_security_group.three_tier_rds_sg.id
}

output "db_subnets" {
  value = aws_subnet.three_tier_private_subnets_db.*.id
}


output "db_subnet_group_name" {
  value = aws_db_subnet_group.three_tier_rds_subnetgroup.*.name
}

output "rds_db_subnet_group" {
  value = aws_db_subnet_group.three_tier_rds_subnetgroup.*.id
}
