# ---------------------------------------------------------------------------------------------------------------------
# PRODUCTION ENVIRONMENT VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "nginx-demo"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Domain name for the application (e.g., app.example.com)"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name (e.g., example.com)"
  type        = string
}

variable "workload_role_arn" {
  description = "ARN of the cross-account IAM role in the workload account"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "desired_count" {
  description = "Initial number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks (autoscaling)"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks (autoscaling)"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
