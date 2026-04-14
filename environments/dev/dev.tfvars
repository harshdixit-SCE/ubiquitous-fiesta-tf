# Personal namespace — change this to your name/alias to avoid conflicts in shared accounts
namespace  = "harsh"

# Environment
env        = "dev"
aws_region = "ap-south-1"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Project Tags
project_tags = {
  Environment    = "dev"
  ManagedBy      = "Terraform"
  "caylent:owner" = "harsh.dixit@caylent.com"
}

# Database Configuration (non-sensitive)
db_username             = "admin"
db_name                 = "appdb"
instance_class          = "db.t3.micro"
allocated_storage       = 20
engine_version          = "8.0"
backup_retention_period = 7
skip_final_snapshot     = true

# ASG Configuration
instance_type        = "t3.micro"
app_min_size         = 1
app_max_size         = 2
app_desired_capacity = 1
