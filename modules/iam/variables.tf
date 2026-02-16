# ---------------------------------------------------------------------------------------------------------------------
# IAM MODULE VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for IAM role names"
  type        = string
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
