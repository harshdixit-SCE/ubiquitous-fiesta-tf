variable "project_tags" {
  type        = map(string)
  description = "Standard Caylent tagging requirements for all resources"
  # You can keep the default empty or define the mandatory keys here
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}