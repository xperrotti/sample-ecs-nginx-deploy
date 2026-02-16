# ---------------------------------------------------------------------------------------------------------------------
# ACM MODULE VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "domain_name" {
  description = "Domain name for the ACM certificate (e.g., app.example.com)"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name (e.g., example.com)"
  type        = string
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
