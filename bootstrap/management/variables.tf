# ---------------------------------------------------------------------------------------------------------------------
# MANAGEMENT ACCOUNT BOOTSTRAP VARIABLES
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

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "workload_account_id" {
  description = "AWS account ID for the workload account"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
