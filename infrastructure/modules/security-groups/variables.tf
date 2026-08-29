# ==============================================================================
# SECURITY GROUP VARIABLES
# These variables allow us to deploy the exact same security group rules across
# different environments (dev, staging, prod) simply by changing the inputs.
# ==============================================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  # Note for juniors: We use this to ensure all resources created by this module
  # share a consistent prefix. This makes identifying resources in the AWS Console
  # and tracking billing much easier!
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  # Example: "dev", "qa", or "prod". This is usually combined with the project_name
  # to dynamically name the security groups (e.g., "myapp-prod-alb-sg").
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
  # Crucial context: Security groups are VPC-specific boundaries. You cannot create
  # a security group without explicitly telling AWS which Virtual Private Cloud
  # network it belongs to. You would typically pass the 'vpc_id' output from your
  # network module into this variable.
}

variable "app_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 3000
  # Since different applications run on different ports (e.g., Node.js often on 3000,
  # Spring Boot on 8080), this variable makes the module reusable for different apps.
  # By setting 'default = 3000', we make this variable optional; if the user doesn't
  # provide a port, Terraform will automatically assume 3000.
}
