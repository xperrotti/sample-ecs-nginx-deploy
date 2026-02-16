# ---------------------------------------------------------------------------------------------------------------------
# IAM MODULE
# Creates ECS task execution role and task role
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK EXECUTION ROLE
# Used by the ECS agent to pull images from ECR and write logs to CloudWatch
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-task-execution"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK ROLE
# Used by the application container at runtime — minimal for nginx (no AWS API calls)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task" {
  name               = "${var.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-task"
  })
}
