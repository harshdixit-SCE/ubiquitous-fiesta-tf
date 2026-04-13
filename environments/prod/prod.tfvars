# Environment
env        = "prod"
aws_region = "us-east-1"

# VPC Configuration
vpc_cidr = "10.1.0.0/16"

# Project Tags
project_tags = {
  Environment = "prod"
  ManagedBy   = "Terraform"
}

# Database Configuration (non-sensitive)
db_name                 = "appdb"
instance_class          = ""
allocated_storage       =
engine_version          = "8.0"
backup_retention_period =
skip_final_snapshot     = false
