module "network" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  env          = var.env
  namespace    = var.namespace
  project_tags = var.project_tags
}

module "database" {
  source = "./modules/rds"

  env          = var.env
  namespace    = var.namespace
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
  vpc_cidr     = module.network.vpc_cidr
  project_tags = var.project_tags

  # Database Configuration
  db_username             = var.db_username
  db_name                 = var.db_name
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  engine_version          = var.engine_version
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
}
