# Environment
variable "env" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
}

# Project Tags
variable "project_tags" {
  type        = map(string)
  description = "Standard Caylent tagging requirements for all resources"
}

# VPC Configuration
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

# Database Non-Sensitive Configuration
variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
}

variable "engine_version" {
  type        = string
  description = "MySQL engine version"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on deletion"
}

# Database Sensitive Variables
variable "db_username" {
  type        = string
  description = "Database master username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}
