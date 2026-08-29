# ==============================================================================
# DATA SOURCES
# Data blocks allow Terraform to "read" information from AWS that already exists,
# rather than creating something new.
# ==============================================================================
data "aws_availability_zones" "available" {
  state = "available"
  # Note for juniors: This queries AWS for all currently healthy and available
  # Availability Zones in the region you are deploying to (e.g., us-east-1a, us-east-1b).
}

# ==============================================================================
# LOCALS
# ==============================================================================
locals {
  # We use the built-in 'slice' function to take the list of available AZs we just
  # queried above and grab exactly the first two (index 0 and 1).
  # This ensures we satisfy our VPC module's requirement for at least 2 AZs
  # without hardcoding specific names like "us-east-1a", making the code portable.
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ==============================================================================
# VPC MODULE INSTANTIATION
# Here we are "calling" the reusable VPC module we created earlier.
# This specific file is for the 'dev' environment, so we configure it accordingly.
# ==============================================================================
module "vpc" {
  # 'source' tells Terraform where to find the underlying code for this module.
  source = "../../modules/vpc"

  name = "${var.project_name}-${var.environment}"

  vpc_cidr = var.vpc_cidr

  # Passing in the 2 AZs we sliced dynamically above.
  availability_zones = local.availability_zones

  # For a dev environment, it is common to hardcode these CIDR blocks directly
  # in the module call to keep things simple and easy to read.
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  private_db_subnet_cidrs = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]

  # Keep NAT disabled for this networking-only milestone.
  # Enable it later when private ECS tasks require outbound access.
  enable_nat_gateway = var.enable_nat_gateway

  # We force this to 'true' in dev to save money by only provisioning one NAT Gateway
  # for the entire environment, regardless of the default module setting.
  single_nat_gateway = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ==============================================================================
# SECURITY GROUPS MODULE INSTANTIATION
# ==============================================================================
module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  # IMPLICIT DEPENDENCY: By referencing 'module.vpc.vpc_id', we tell Terraform two things:
  # 1. Take the vpc_id output from the VPC module and pass it in here as a variable.
  # 2. Wait until the VPC is fully created BEFORE trying to create the Security Groups.
  vpc_id = module.vpc.vpc_id

  app_port = 3000
}
