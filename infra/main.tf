module "network" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  env          = var.env
  namespace    = var.namespace
  project_tags = var.project_tags
}

# App ALB — internal, in private subnets, accepts traffic from web instances
module "app_alb" {
  source       = "./modules/alb"
  namespace    = var.namespace
  env          = var.env
  name         = "app"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
  internal     = true
  ingress_cidr = module.network.vpc_cidr
  project_tags = var.project_tags
}

# App ASG — in private subnets, only accepts traffic from app ALB
module "app" {
  source                = "./modules/asg"
  namespace             = var.namespace
  env                   = var.env
  name                  = "app"
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_subnet_ids
  alb_security_group_id = module.app_alb.security_group_id
  target_group_arn      = module.app_alb.target_group_arn
  instance_type         = var.instance_type
  min_size              = var.app_min_size
  max_size              = var.app_max_size
  desired_capacity      = var.app_desired_capacity
  user_data             = templatefile("${path.module}/templates/app_user_data.sh", {
    db_endpoint = module.database.db_instance_address
    db_port     = module.database.db_instance_port
    db_username = var.db_username
  })
  project_tags          = var.project_tags
}

# Web ALB — internet-facing, in public subnets, accepts traffic from internet
module "web_alb" {
  source       = "./modules/alb"
  namespace    = var.namespace
  env          = var.env
  name         = "web"
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnet_ids
  internal     = false
  ingress_cidr = "0.0.0.0/0"
  project_tags = var.project_tags
}

# Web ASG — in public subnets, only accepts traffic from web ALB
module "web" {
  source                = "./modules/asg"
  namespace             = var.namespace
  env                   = var.env
  name                  = "web"
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.public_subnet_ids
  alb_security_group_id = module.web_alb.security_group_id
  target_group_arn      = module.web_alb.target_group_arn
  instance_type         = var.instance_type
  min_size              = var.web_min_size
  max_size              = var.web_max_size
  desired_capacity      = var.web_desired_capacity
  user_data             = templatefile("${path.module}/templates/web_user_data.sh", {
    app_alb_dns = module.app_alb.alb_dns_name
  })
  project_tags          = var.project_tags
}

module "database" {
  source = "./modules/rds"

  env                   = var.env
  namespace             = var.namespace
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
  vpc_cidr     = module.network.vpc_cidr
  project_tags = var.project_tags

  db_username             = var.db_username
  db_name                 = var.db_name
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  engine_version          = var.engine_version
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
}
