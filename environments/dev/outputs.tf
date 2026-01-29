output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway"
  value       = module.network.nat_gateway_public_ip
}
