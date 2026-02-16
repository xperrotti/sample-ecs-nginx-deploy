# ---------------------------------------------------------------------------------------------------------------------
# WORKLOAD ACCOUNT BOOTSTRAP OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------

output "workload_role_arn" {
  description = "ARN of the workload IAM role for cross-account access"
  value       = aws_iam_role.github_actions_workload.arn
}

output "workload_role_name" {
  description = "Name of the workload IAM role"
  value       = aws_iam_role.github_actions_workload.name
}
