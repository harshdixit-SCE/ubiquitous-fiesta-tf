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
  description = "Logical name for this ALB (e.g., web, app) — used in resource naming"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ALB (public for web, private for app)"
}

variable "internal" {
  type        = bool
  description = "Whether the ALB is internal (true for app layer, false for web layer)"
  default     = false
}

variable "target_port" {
  type        = number
  description = "Port the target instances listen on"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "HTTP path for ALB health checks"
  default     = "/"
}

variable "ingress_cidr" {
  type        = string
  description = "CIDR block allowed to reach the ALB (0.0.0.0/0 for web, VPC CIDR for app)"
}

variable "project_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
