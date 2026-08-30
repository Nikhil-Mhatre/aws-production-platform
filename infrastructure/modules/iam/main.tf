# ==============================================================================
# 1. ECS TASK EXECUTION ROLE (Infrastructure / Agent Level)
#
# What is it?
# This role is used by the AWS ECS Infrastructure/Agent itself BEFORE and WHILE
# starting your container. The ECS agent needs permissions to pull your Docker
# image from ECR and configure logging to CloudWatch.
# ==============================================================================

resource "aws_iam_role" "ecs_execution" {
  # Dynamically sets the role name using project and environment variables. Example: name = "myapp-prod-ecs-execution-role"
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  # Converts the provided IAM policy map into a JSON string required by AWS. Example: assume_role_policy = jsonencode({ "Statement": [] })
  assume_role_policy = jsonencode({
    # Specifies the standard IAM policy language version. Example: Version = "2012-10-17"
    Version = "2012-10-17"

    # Begins a list of permission statements. Example: Statement = [ { Effect = "Allow" } ]
    Statement = [
      # Starts the first statement block. Example: { Effect = "Deny" }
      {
        # Grants the specified permission rather than denying it. Example: Effect = "Allow"
        Effect = "Allow"

        # Defines WHO (the principal) is allowed to assume this role. Example: Principal = { AWS = "arn:aws:iam::123456789012:root" }
        Principal = {
          # Specifies that the AWS ECS Tasks service is the allowed principal. Example: Service = "ec2.amazonaws.com"
          Service = "ecs-tasks.amazonaws.com"
          # Ends the Principal map.
        }

        # Specifies the exact action allowed, which is assuming the role. Example: Action = "sts:AssumeRole"
        Action = "sts:AssumeRole"
        # Ends the statement block.
      }
      # Ends the list of statements.
    ]
    # Ends the jsonencode function for the assume_role_policy.
  })

  # Applies tags to the IAM role. Example: tags = { Owner = "DevOps" }
  tags = {
    # Dynamically generates the Name tag. Example: Name = "myapp-prod-ecs-execution-role"
    Name = "${var.project_name}-${var.environment}-ecs-execution-role"
    # Tags the role with the project name. Example: Project = "DataPipeline"
    Project = var.project_name
    # Tags the role with the current environment. Example: Environment = "staging"
    Environment = var.environment
    # Indicates this resource is managed via code. Example: ManagedBy = "Terraform"
    ManagedBy = "Terraform"
    # Ends the tags map.
  }
  # Ends the ecs_execution aws_iam_role resource block.
}

# ==============================================================================
# ECS TASK EXECUTION ROLE POLICY (Permissions)
#
# Best Practice Highlight:
# Instead of attaching the broad AWS-managed policy (AmazonECSTaskExecutionRolePolicy),
# this custom inline policy enforces the Principle of Least Privilege by restricting
# image pulling strictly to your specific ECR repository ARN.
# ==============================================================================

# Declares an inline IAM policy resource attached directly to a role. Example: resource "aws_iam_role_policy" "s3_access" {
resource "aws_iam_role_policy" "ecs_execution" {
  # Dynamically names the policy. Example: name = "myapp-prod-ecs-execution-policy"
  name = "${var.project_name}-${var.environment}-ecs-execution-policy"
  # Attaches this policy to the ID of the IAM role created above. Example: role = aws_iam_role.my_role.id
  role = aws_iam_role.ecs_execution.id

  # Converts the IAM permission rules into a JSON string. Example: policy = jsonencode({ "Version": "2012-10-17" })
  policy = jsonencode({
    # Uses the standard IAM policy version date. Example: Version = "2012-10-17"
    Version = "2012-10-17"

    # Begins the list of policy statements defining what the role can do. Example: Statement = [ { Action = "*" } ]
    Statement = [
      # Statement 1: Get authorization token to log in to AWS ECR.
      # (Must be Resource = "*" because the auth token is scoped at the AWS account level).
      # Starts the first statement block.
      {
        # Provides an optional identifier (Statement ID) for this block. Example: Sid = "AllowS3Read"
        Sid = "EcrPull"
        # Grants access for the specified actions. Example: Effect = "Allow"
        Effect = "Allow"

        # Lists the specific API actions allowed. Example: Action = [ "s3:GetObject" ]
        Action = [
          # Allows the ECS agent to authenticate with the ECR registry. Example: "ecr:GetAuthorizationToken"
          "ecr:GetAuthorizationToken"
          # Ends the Action list.
        ]

        # Applies the action to all resources (required for the GetAuthorizationToken API). Example: Resource = "*"
        Resource = "*"
        # Ends the first statement block.
      },
      # Statement 2: Pull container layers and manifests strictly from our project's ECR repository.
      # Starts the second statement block.
      {
        # Identifies this statement's purpose. Example: Sid = "EcrRepositoryPull"
        Sid = "EcrRepositoryPull"
        # Grants the permission. Example: Effect = "Allow"
        Effect = "Allow"

        # Lists the specific ECR pull actions required to download an image. Example: Action = [ "ecr:BatchGetImage" ]
        Action = [
          # Allows checking if the image layers already exist. Example: "ecr:BatchCheckLayerAvailability"
          "ecr:BatchCheckLayerAvailability",
          # Allows fetching the actual download URL for the image layer. Example: "ecr:GetDownloadUrlForLayer"
          "ecr:GetDownloadUrlForLayer",
          # Allows fetching the image manifest/details. Example: "ecr:BatchGetImage"
          "ecr:BatchGetImage"
          # Ends the Action list.
        ]

        # Restricts these pull actions securely to just your specific ECR repository. Example: Resource = "arn:aws:ecr:us-east-1:123:repository/my-repo"
        Resource = var.ecr_repository_arn
        # Ends the second statement block.
      },
      # Statement 3: Stream container logs (stdout/stderr) directly into CloudWatch Logs.
      # Starts the third statement block.
      {
        # Identifies this statement as managing CloudWatch logging. Example: Sid = "CloudWatchLogs"
        Sid = "CloudWatchLogs"
        # Grants the permission. Example: Effect = "Allow"
        Effect = "Allow"

        # Lists the actions needed to send logs to CloudWatch. Example: Action = [ "logs:PutLogEvents" ]
        Action = [
          # Allows creating a new log stream inside a CloudWatch log group. Example: "logs:CreateLogStream"
          "logs:CreateLogStream",
          # Allows writing the actual log lines to the stream. Example: "logs:PutLogEvents"
          "logs:PutLogEvents"
          # Ends the Action list.
        ]

        # Restrict ECS logging permissions to the application's CloudWatch
        # log group rather than allowing access to every log group in the account.
        #
        # The :* suffix covers the log streams created under this log group.
        Resource = "${var.cloudwatch_log_group_arn}:*"
        # Ends the third statement block.
      }
      # Ends the list of policy statements.
    ]
    # Ends the jsonencode function for the policy.
  })
  # Ends the ecs_execution aws_iam_role_policy resource block.
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

# Declares an IAM role resource for the actual container application task. Example: resource "aws_iam_role" "app_task" {
resource "aws_iam_role" "ecs_task" {
  # Dynamically names the task role. Example: name = "myapp-prod-ecs-task-role"
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  # Trust Policy: Allows the ECS task container to assume this identity at runtime. Example: assume_role_policy = jsonencode(...)
  assume_role_policy = jsonencode({
    # Standard policy version. Example: Version = "2012-10-17"
    Version = "2012-10-17"

    # Begins the trust policy statements. Example: Statement = [ { Effect = "Allow" } ]
    Statement = [
      # Starts the assumption statement. Example: { Effect = "Allow" }
      {
        # Grants assumption rights. Example: Effect = "Allow"
        Effect = "Allow"

        # Specifies the AWS entity allowed to assume the role. Example: Principal = { Service = "ecs-tasks.amazonaws.com" }
        Principal = {
          # Grants the ECS Tasks service the right to adopt this role on behalf of your app. Example: Service = "ecs-tasks.amazonaws.com"
          Service = "ecs-tasks.amazonaws.com"
          # Ends the Principal map.
        }

        # The API action to assume the role. Example: Action = "sts:AssumeRole"
        Action = "sts:AssumeRole"
        # Ends the statement block.
      }
      # Ends the Statement list.
    ]
    # Ends the jsonencode function.
  })

  # Tags for the task role resource. Example: tags = { RoleType = "Task" }
  tags = {
    # Dynamically generates Name tag. Example: Name = "myapp-prod-ecs-task-role"
    Name = "${var.project_name}-${var.environment}-ecs-task-role"
    # Tags project name. Example: Project = "Analytics"
    Project = var.project_name
    # Tags environment. Example: Environment = "prod"
    Environment = var.environment
    # Tags management tool. Example: ManagedBy = "Terraform"
    ManagedBy = "Terraform"
    # Ends the tags map.
  }
  # Ends the ecs_task aws_iam_role resource block.
}
