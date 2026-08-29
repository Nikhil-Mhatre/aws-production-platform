# ==============================================================================
# 1. ECS TASK EXECUTION ROLE (Infrastructure / Agent Level)
#
# What is it?
# This role is used by the AWS ECS Infrastructure/Agent itself BEFORE and WHILE
# starting your container. The ECS agent needs permissions to pull your Docker
# image from ECR and configure logging to CloudWatch.
# ==============================================================================
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  # Trust Policy: Specifies WHO is allowed to assume this IAM role.
  # Here, we allow the AWS ECS service ("ecs-tasks.amazonaws.com") to assume it.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-execution-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# ECS TASK EXECUTION ROLE POLICY (Permissions)
#
# Best Practice Highlight:
# Instead of attaching the broad AWS-managed policy (AmazonECSTaskExecutionRolePolicy),
# this custom inline policy enforces the Principle of Least Privilege by restricting
# image pulling strictly to your specific ECR repository ARN.
# ==============================================================================
resource "aws_iam_role_policy" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-policy"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      # Statement 1: Get authorization token to log in to AWS ECR.
      # (Must be Resource = "*" because the auth token is scoped at the AWS account level).
      {
        Sid    = "EcrPull"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      # Statement 2: Pull container layers and manifests strictly from our project's ECR repository.
      {
        Sid    = "EcrRepositoryPull"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]

        Resource = var.ecr_repository_arn
      },
      # Statement 3: Stream container logs (stdout/stderr) directly into CloudWatch Logs.
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }
    ]
  })
}

# ==============================================================================
# 2. ECS TASK ROLE (Application Code Level)
#
# What is it?
# This role is used by YOUR APPLICATION running inside the container.
# If your application code (e.g., Node.js / Python / Java) needs to interact with
# other AWS services (like reading from an S3 bucket or querying DynamoDB),
# you attach those permissions to this role.
#
# Note: It has an empty permission set right now because the base container
# doesn't need external AWS service access yet.
# ==============================================================================
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  # Trust Policy: Allows the ECS task container to assume this identity at runtime.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
