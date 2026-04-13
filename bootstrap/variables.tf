variable "state_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Terraform state storage (must be globally unique)"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create the state bucket and lock table"
  default     = "us-east-1"
}
