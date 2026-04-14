variable "namespace" {
  type        = string
  description = "Personal namespace to avoid resource name conflicts"
}

variable "env" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "name" {
  type        = string
  description = "Logical name for this ASG (e.g., web, app) — used in resource naming"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where instances will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ASG instances (private for app, public for web)"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID of the ALB — instances only accept traffic from this SG"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group to register instances with"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances in the ASG"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in the ASG"
  default     = 3
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in the ASG"
  default     = 2
}

variable "cpu_target_value" {
  type        = number
  description = "Target CPU utilization percentage for auto scaling"
  default     = 60
}

variable "user_data" {
  type        = string
  description = "User data script to run on instance launch"
  default     = ""
}

variable "project_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
