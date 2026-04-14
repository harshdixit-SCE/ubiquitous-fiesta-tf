# Environment and Network Variables
variable "env" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "namespace" {
  type        = string
  description = "Personal namespace to avoid resource name conflicts in shared accounts (e.g., your name/alias)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for DB subnet group"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block for security group rules"
}

variable "project_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default     = {}
}

# Database Configuration Variables
variable "db_name" {
  type        = string
  description = "Name of the initial database to create"
}

variable "db_username" {
  type        = string
  description = "Master username for the database"
}

# RDS Instance Configuration
variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "engine_version" {
  type        = string
  description = "MySQL engine version"
  default     = "8.0"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 7
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on deletion (set to false for production)"
  default     = false
}

