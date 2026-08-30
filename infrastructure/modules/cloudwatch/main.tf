# ==============================================================================
# CLOUDWATCH LOG GROUP
# ==============================================================================
# This log group is used by ECS Fargate to store application/container logs
# for the LaunchPad API.
#
# ECS containers write their stdout/stderr output to this log group through
# the AWS CloudWatch Logs integration.
#
# The log group is deliberately managed by Terraform so that:
#
# - Its name is consistent across environments
# - Log retention is controlled as code
# - The ECS IAM execution role can be restricted to this log group
# - Development and production environments can use different retention
#   policies
# ==============================================================================

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/aws/ecs/${var.project_name}-${var.environment}"

  # Keep development logs for a limited period to control storage costs.
  #
  # This value is configurable so production can retain logs for longer.
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "/aws/ecs/${var.project_name}-${var.environment}"
  })
}
