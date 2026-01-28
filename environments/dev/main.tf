module "network" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  env          = "dev"
  project_tags = var.project_tags # Passed from dev variables.tf
}