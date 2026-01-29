module "network" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  env          = "dev"
  project_tags = var.project_tags # Passed from dev variables.tf
}

module "database" {
  source = "../../modules/rds"

  env          = "dev"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
  vpc_cidr     = module.network.vpc_cidr
  project_tags = var.project_tags

  # Database Configuration
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  engine_version      = "8.0"
  skip_final_snapshot = true # For dev environment only
}