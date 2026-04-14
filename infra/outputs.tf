output "web_alb_dns" {
  description = "Public DNS name of the web ALB — use this to access the application"
  value       = module.web_alb.alb_dns_name
}

output "app_alb_dns" {
  description = "Internal DNS name of the app ALB"
  value       = module.app_alb.alb_dns_name
}

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

# RDS Outputs
output "rds_endpoint" {
  description = "RDS MySQL endpoint (hostname:port)"
  value       = module.database.db_instance_endpoint
}

output "rds_address" {
  description = "RDS MySQL hostname"
  value       = module.database.db_instance_address
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = module.database.db_instance_port
}

output "rds_database_name" {
  description = "Name of the created database"
  value       = module.database.db_name
}

output "rds_security_group_id" {
  description = "Security group ID for RDS access"
  value       = module.database.security_group_id
}
