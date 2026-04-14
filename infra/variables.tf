# Environment
variable "env" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "namespace" {
  type        = string
  description = "Personal namespace to avoid resource name conflicts in shared accounts (e.g., your name/alias)"
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
variable "db_username" {
  type        = string
  description = "Master username for the database"
}

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

# ASG Configuration
variable "instance_type" {
  type        = string
  description = "EC2 instance type for ASG instances"
  default     = "t3.micro"
}

variable "web_min_size" {
  type        = number
  description = "Minimum number of web instances"
  default     = 1
}

variable "web_max_size" {
  type        = number
  description = "Maximum number of web instances"
  default     = 3
}

variable "web_desired_capacity" {
  type        = number
  description = "Desired number of web instances"
  default     = 2
}

variable "app_min_size" {
  type        = number
  description = "Minimum number of app instances"
  default     = 1
}

variable "app_max_size" {
  type        = number
  description = "Maximum number of app instances"
  default     = 3
}

variable "app_desired_capacity" {
  type        = number
  description = "Desired number of app instances"
  default     = 2
}


