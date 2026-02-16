project_name       = "nginx-demo"
region             = "us-east-2"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
vpc_cidr           = "10.0.0.0/16"
domain_name        = "nginx-demo.ciphercoat.com"
hosted_zone_name   = "ciphercoat.com"
workload_role_arn  = "arn:aws:iam::123456789098:role/nginx-demo-github-actions-workload"
image_tag          = "latest"
desired_count      = 2
min_capacity       = 2
max_capacity       = 20

tags = {
  Owner = "perrotti"
}
