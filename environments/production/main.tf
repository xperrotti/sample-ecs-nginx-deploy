# ---------------------------------------------------------------------------------------------------------------------
# PRODUCTION ENVIRONMENT
# Root module that composes all infrastructure modules for the ECS Fargate deployment
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}

# Default provider — workload account (ECS, ALB, VPC, ECR, IAM)
provider "aws" {
  region = var.region

  assume_role {
    role_arn = var.workload_role_arn
  }

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

# DNS provider — management account (Route53 hosted zone lives here)
# Uses the default OIDC credentials without assume_role
provider "aws" {
  alias  = "dns"
  region = var.region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project_name}-vpc"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = var.project_name
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ACM CERTIFICATE (cert in workload account, DNS validation in management account)
# ---------------------------------------------------------------------------------------------------------------------

module "acm" {
  source = "../../modules/acm"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  domain_name      = var.domain_name
  hosted_zone_name = var.hosted_zone_name
  tags             = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER (ALB in workload account, Route53 alias in management account)
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  name              = "${var.project_name}-alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  certificate_arn   = module.acm.certificate_arn
  domain_name       = var.domain_name
  hosted_zone_id    = module.acm.hosted_zone_id
  tags              = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ECR REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "${var.project_name}-nginx-hello"
  tags            = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLES
# ---------------------------------------------------------------------------------------------------------------------

module "iam" {
  source = "../../modules/iam"

  name_prefix = var.project_name
  tags        = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER + SERVICE
# ---------------------------------------------------------------------------------------------------------------------

module "ecs" {
  source = "../../modules/ecs"

  cluster_name            = "${var.project_name}-cluster"
  service_name            = "${var.project_name}-service"
  ecr_repository_url      = module.ecr.repository_url
  image_tag               = var.image_tag
  region                  = var.region
  private_subnet_ids      = module.vpc.private_subnet_ids
  ecs_security_group_id   = module.security_groups.ecs_security_group_id
  target_group_arn        = module.alb.target_group_arn
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn
  desired_count           = var.desired_count
  min_capacity            = var.min_capacity
  max_capacity            = var.max_capacity
  tags                    = var.tags
}
