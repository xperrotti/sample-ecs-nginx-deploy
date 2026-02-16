# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM BACKEND CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    # Configured via -backend-config flags in CI/CD:
    # bucket         = "terraform-state-nginx-demo-ACCOUNT_ID"
    # key            = "production/terraform.tfstate"
    # region         = "us-east-2"
    # encrypt        = true
    # dynamodb_table = "terraform-locks-nginx-demo"
  }
}
