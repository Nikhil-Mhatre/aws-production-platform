data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "../../modules/vpc"

  name = "${var.project_name}-${var.environment}"

  vpc_cidr = var.vpc_cidr

  availability_zones = local.availability_zones

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
  single_nat_gateway = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
