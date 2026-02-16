# ---------------------------------------------------------------------------------------------------------------------
# WORKLOAD ACCOUNT BOOTSTRAP
# Creates the IAM role that the management account's GitHub Actions role can assume.
# This enables cross-account Terraform operations from CI/CD.
#
# This must be applied manually with local admin credentials to the workload account.
# State is stored locally.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # NO backend block — state is local
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Purpose   = "bootstrap"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLE TRUSTED BY MANAGEMENT ACCOUNT
# The GitHub Actions role in the management account assumes this role for cross-account operations
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "github_actions_workload" {
  name = "${var.project_name}-github-actions-workload"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.management_account_id}:role/${var.project_name}-github-actions"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM POLICY: WORKLOAD INFRASTRUCTURE PERMISSIONS
# Grants the permissions needed to manage all infrastructure in this account
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "workload_permissions" {
  name = "terraform-workload-permissions"
  role = aws_iam_role.github_actions_workload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCManagement"
        Effect = "Allow"
        Action = [
          "ec2:*Vpc*",
          "ec2:*Subnet*",
          "ec2:*RouteTable*",
          "ec2:*Route*",
          "ec2:*InternetGateway*",
          "ec2:*NatGateway*",
          "ec2:*Address*",
          "ec2:*SecurityGroup*",
          "ec2:*NetworkInterface*",
          "ec2:*NetworkAcl*",
          "ec2:*Tags*",
          "ec2:Describe*",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSManagement"
        Effect = "Allow"
        Action = [
          "ecs:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ELBManagement"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRManagement"
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ACMManagement"
        Effect = "Allow"
        Action = [
          "acm:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Route53Management"
        Effect = "Allow"
        Action = [
          "route53:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:PassRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRoleTags",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      },
      {
        Sid    = "AppAutoscaling"
        Effect = "Allow"
        Action = [
          "application-autoscaling:*"
        ]
        Resource = "*"
      }
    ]
  })
}
