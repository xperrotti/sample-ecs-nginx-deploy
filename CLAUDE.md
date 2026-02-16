# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform infrastructure deploying nginxdemos/hello on AWS ECS Fargate behind an ALB with HTTPS, auto-scaling, and multi-account separation. Uses a management account (Terraform state, OIDC, Route53) and a workload account (ECS, ALB, VPC, ECR).

## Common Commands

### Terraform (from environments/production/)
```bash
# Initialize with remote backend (CI/CD populates these via GitHub secrets)
terraform init \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="key=production/terraform.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="dynamodb_table=$TF_LOCK_TABLE"

terraform plan
terraform apply
terraform destroy
```

### Bootstrap (one-time, from bootstrap/management/ or bootstrap/workload/)
```bash
terraform init
terraform apply
```

### Validate and format
```bash
terraform fmt -recursive    # Format all .tf files
terraform validate          # Validate configuration (run from environments/production/)
```

### Architecture diagram (from diagrams/)
```bash
pip install -r requirements.txt
python architecture.py      # Outputs diagrams/architecture.png
```

## Architecture

### Multi-Account Dual-Provider Pattern
The root module (`environments/production/main.tf`) uses two AWS providers:
- **Default provider** (`aws`): assumes a role into the workload account for compute resources (ECS, ALB, VPC, ECR, IAM)
- **Aliased provider** (`aws.dns`): uses management account credentials for Route53 DNS records

Modules needing both providers (acm, alb) declare `providers = { aws = aws, aws.dns = aws.dns }`.

### Module Composition Order
All modules are composed in `environments/production/main.tf` with this dependency chain:
```
vpc → security_groups → acm → alb → ecr → iam → ecs
```
Key inter-module references: VPC outputs subnet IDs and VPC ID; security_groups outputs SG IDs; acm outputs certificate ARN and hosted zone ID; alb outputs target group ARN; ecr outputs repository URL; iam outputs role ARNs.

### Module Structure Convention
Each module follows: `main.tf` (resources), `variables.tf` (inputs), `outputs.tf` (outputs). Some modules also declare `providers.tf` for cross-account provider requirements.

### CI/CD Workflows
- **terraform-plan.yml**: PR to master → plan + comment on PR
- **terraform-apply.yml**: push to master → apply with environment approval gate
- **ecr-sync.yml**: weekly/manual → mirror Docker Hub image to ECR, optional ECS force-deploy

GitHub Actions authenticate via OIDC (no stored AWS credentials). The workflow assumes the management account role first, then chains to the workload account role.

### Known Patterns
- `time_sleep` resource in ECS module delays service creation for IAM role propagation
- S3 state bucket and DynamoDB lock table have `prevent_destroy = true` lifecycle rules
- ACM uses `create_before_destroy` for zero-downtime certificate rotation
- Resource naming convention: `{project_name}-{component}` (e.g., `nginx-demo-vpc`, `nginx-demo-alb`)
- Provider-level `default_tags` apply Project/Environment/ManagedBy to all resources

## Required GitHub Secrets
`AWS_ROLE_ARN`, `WORKLOAD_ROLE_ARN`, `TF_STATE_BUCKET`, `TF_LOCK_TABLE`, `DOMAIN_NAME`, `HOSTED_ZONE_NAME`

## Versions
- Terraform >= 1.5.0
- AWS provider >= 5.0
- Time provider >= 0.9
