# ---------------------------------------------------------------------------------------------------------------------
# WORKLOAD ACCOUNT BOOTSTRAP VARIABLES
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

variable "management_account_id" {
  description = "AWS account ID of the management account"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
