variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "project_tags" {
  type        = map(string)
  description = "Standard Caylent tagging requirements"
}

variable "env" {
  type        = string
  description = "Environment name (e.g., dev)"
}