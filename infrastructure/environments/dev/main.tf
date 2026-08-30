# ==============================================================================
# DATA SOURCES
# ==============================================================================
# Data sources allow Terraform to retrieve information about existing AWS
# infrastructure instead of creating new resources.
#
# Here, we ask AWS which Availability Zones are currently available in the
# configured region. This avoids hardcoding AZ names such as "us-east-1a".
# ==============================================================================

data "aws_availability_zones" "available" {
  # Only return Availability Zones that are currently available for use.
  state = "available"
}


# ==============================================================================
# LOCAL VALUES
# ==============================================================================
# Local values are reusable expressions that simplify the configuration below.
# ==============================================================================

locals {
  # Select the first two available Availability Zones.
  #
  # We need at least two AZs for our production-oriented architecture so that
  # application resources can eventually be distributed across multiple
  # physical locations within the AWS region.
  #
  # Using dynamically discovered AZs makes this configuration more portable
  # than hardcoding names such as "us-east-1a" and "us-east-1b".
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )
}


# ==============================================================================
# VPC MODULE
# ==============================================================================
# This module creates the network foundation for the LaunchPad API platform.
#
# The VPC module is responsible for creating:
#
# - VPC
# - Internet Gateway
# - Public subnets
# - Private application subnets
# - Private database subnets
# - Route tables
# - Route table associations
# - NAT Gateway, when enabled
#
# The actual reusable Terraform code lives under:
#
# infrastructure/modules/vpc/
#
# This file only supplies environment-specific configuration to that module.
# ==============================================================================

module "vpc" {
  # Location of the reusable VPC module relative to this environment.
  source = "../../modules/vpc"

  # Name used for the VPC and related resources.
  #
  # Example:
  # aws-production-platform-dev
  name = "${var.project_name}-${var.environment}"

  # CIDR block defining the private IP address range of the VPC.
  #
  # Example:
  # 10.0.0.0/16
  vpc_cidr = var.vpc_cidr

  # Pass the two Availability Zones selected above into the VPC module.
  availability_zones = local.availability_zones

  # --------------------------------------------------------------------------
  # PUBLIC SUBNETS
  # --------------------------------------------------------------------------
  # These subnets are intended for resources that need a public-facing
  # network path.
  #
  # In our final architecture, the Application Load Balancer will use these
  # subnets.
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  # --------------------------------------------------------------------------
  # PRIVATE APPLICATION SUBNETS
  # --------------------------------------------------------------------------
  # These subnets are intended for ECS Fargate application tasks.
  #
  # The application containers should not be directly accessible from the
  # public internet. Internet-facing traffic will first reach the ALB and
  # then be forwarded to ECS.
  private_app_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  # --------------------------------------------------------------------------
  # PRIVATE DATABASE SUBNETS
  # --------------------------------------------------------------------------
  # These subnets are reserved for database infrastructure such as
  # Amazon RDS PostgreSQL.
  #
  # The database tier should remain private and should not have a direct
  # internet route.
  private_db_subnet_cidrs = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]

  # --------------------------------------------------------------------------
  # NAT GATEWAY
  # --------------------------------------------------------------------------
  # NAT Gateway allows resources in private subnets to initiate outbound
  # internet connections without making those resources directly reachable
  # from the internet.
  #
  # NAT is currently controlled through a variable because we are keeping
  # the initial development environment cost-conscious.
  #
  # For the current networking milestone, this should remain false.
  # We will enable or replace this mechanism later when ECS requires
  # outbound access.
  enable_nat_gateway = var.enable_nat_gateway

  # When NAT is enabled, use a single NAT Gateway for the dev environment.
  #
  # A production architecture may use one NAT Gateway per AZ for improved
  # availability, but that increases cost.
  #
  # For this portfolio project's dev environment, a single NAT Gateway is
  # intentionally chosen as a cost optimization.
  single_nat_gateway = true

  # Common tags applied to resources created by the VPC module.
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# ==============================================================================
# SECURITY GROUPS MODULE
# ==============================================================================
# This module creates the network-level security boundaries for the
# Application Load Balancer, ECS tasks, and RDS PostgreSQL.
#
# The intended traffic flow is:
#
# Internet
#    |
#    | HTTP/HTTPS
#    v
# ALB Security Group
#    |
#    | TCP 3000
#    v
# ECS Security Group
#    |
#    | TCP 5432
#    v
# RDS Security Group
#
# The security groups use security-group-to-security-group references rather
# than allowing application traffic from the entire internet.
# ==============================================================================

module "security_groups" {
  # Location of the reusable security-groups module.
  source = "../../modules/security-groups"

  # Project and environment are used for resource names and tags.
  project_name = var.project_name
  environment  = var.environment

  # Pass the VPC ID created by the VPC module into the security-groups module.
  #
  # This reference creates an implicit Terraform dependency:
  #
  # VPC
  #  |
  #  v
  # Security Groups
  #
  # Terraform therefore knows that the VPC must exist before it can create
  # security groups inside that VPC.
  vpc_id = module.vpc.vpc_id

  # LaunchPad API listens on port 3000 inside the container.
  #
  # The ECS security group will therefore allow traffic from the ALB
  # security group to TCP port 3000.
  app_port = 3000
}


# ==============================================================================
# AMAZON ECR MODULE
# ==============================================================================
# Amazon Elastic Container Registry (ECR) stores the Docker images used by
# the LaunchPad API.
#
# The intended container deployment flow is:
#
# Developer
#     |
#     v
# Docker image
#     |
#     v
# Amazon ECR
#     |
#     v
# ECS Fargate
#
# The ECR module is responsible for creating the container image repository
# and its associated repository configuration.
# ==============================================================================

module "ecr" {
  # Location of the reusable ECR module.
  source = "../../modules/ecr"

  # Project and environment are used to construct the repository name
  # and resource tags.
  project_name = var.project_name
  environment  = var.environment
}


# ==============================================================================
# IAM MODULE
# ==============================================================================
# This module creates IAM roles required by ECS.
#
# The primary roles are:
#
# 1. ECS Task Execution Role
#    Used by the ECS/Fargate platform to perform infrastructure-level
#    operations such as pulling images from ECR and sending container logs
#    to CloudWatch.
#
# 2. ECS Task Role
#    Represents the permissions available to the actual LaunchPad API
#    application running inside the container.
#
# The application task role will initially have minimal/no additional
# permissions because LaunchPad API does not currently need to call AWS
# APIs directly.
# ==============================================================================

module "iam" {
  # Location of the reusable IAM module.
  source = "../../modules/iam"

  # Project and environment are used for IAM role naming and tagging.
  project_name = var.project_name
  environment  = var.environment

  # Pass the ECR repository ARN created above into the IAM module.
  #
  # This creates another implicit Terraform dependency:
  #
  # ECR Repository
  #      |
  #      | repository ARN
  #      v
  # IAM Execution Role
  #
  # The execution role can therefore be restricted to pulling images from
  # this specific ECR repository instead of granting unrestricted ECR access.
  ecr_repository_arn = module.ecr.repository_arn

  # Restrict CloudWatch Logs access to this project's ECS log group.
  cloudwatch_log_group_arn = module.cloudwatch.log_group_arn

  # Restrict Secrets Manager access to the database secret created and
  # managed by RDS.
  database_secret_arn = module.rds.master_user_secret_arn
}


# ==============================================================================
# VPC ENDPOINTS MODULE
# ==============================================================================
# Provides private connectivity from ECS/private application subnets to
# selected AWS services.
#
# Interface endpoints:
#   ECR API
#   ECR Docker Registry
#   CloudWatch Logs
#   Secrets Manager
#
# Gateway endpoint:
#   S3
#
# AWS-service traffic can therefore avoid the NAT Gateway where supported,
# while general external internet traffic continues to use NAT.
# ==============================================================================

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # VPC created by the VPC module.
  vpc_id = module.vpc.vpc_id

  # Interface endpoints are placed in the private application subnets
  # where ECS Fargate tasks will run.
  private_app_subnet_ids = module.vpc.private_app_subnet_ids

  # The S3 gateway endpoint is associated with these route tables.
  private_app_route_table_ids = module.vpc.private_app_route_table_ids

  # Only ECS tasks are allowed to connect to the interface endpoints.
  ecs_security_group_id = module.security_groups.ecs_security_group_id

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# CLOUDWATCH MODULE
# ==============================================================================
# Creates the CloudWatch Log Group used by ECS Fargate for LaunchPad API
# container logs.
#
# The log group ARN is also passed to the IAM module so that the ECS execution
# role can be restricted to this specific log destination.
# ==============================================================================

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name       = var.project_name
  environment        = var.environment
  log_retention_days = var.log_retention_days

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# RDS POSTGRESQL MODULE
# ==============================================================================
# Creates the private PostgreSQL database used by LaunchPad API.
#
# RDS is placed in the private database subnets and is protected by the RDS
# security group.
#
# ECS will later connect to RDS over TCP/5432.
# ==============================================================================

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  # PostgreSQL configuration.
  engine_version = "16"
  instance_class = "db.t4g.micro"

  database_name   = "launchpad"
  master_username = "launchpad_admin"

  # Keep the development database small.
  allocated_storage     = 20
  max_allocated_storage = 100

  # RDS is placed only in private database subnets.
  private_db_subnet_ids = module.vpc.private_db_subnet_ids

  # Only ECS is allowed to connect to PostgreSQL through the RDS security
  # group configured earlier.
  rds_security_group_id = module.security_groups.rds_security_group_id

  # Keep seven days of automated backups for development.
  backup_retention_period = 7

  # Development environment can be destroyed and recreated.
  deletion_protection = false
  skip_final_snapshot = true

  # Apply infrastructure changes during the normal maintenance window where
  # possible.
  apply_immediately = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# ECS FARGATE MODULE
# ==============================================================================
# Deploys the LaunchPad API as a stateless ECS Fargate service.
#
# Tasks run in private application subnets and do not receive public IP
# addresses.
#
# The service will later be connected to the Application Load Balancer through
# the target group ARN.
# ==============================================================================

module "ecs" {
  source = "../../modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # --------------------------------------------------------------------------
  # CONTAINER
  # --------------------------------------------------------------------------

  container_name = "launchpad-api"

  # For the first manual deployment, this will be the image pushed to ECR.
  #
  # We will later replace the tag with an immutable image reference generated
  # by GitHub Actions.
  container_image = "${module.ecr.repository_url}:latest"

  container_port = 3000

  node_environment = "production"

  # --------------------------------------------------------------------------
  # COMPUTE
  # --------------------------------------------------------------------------

  task_cpu    = 256
  task_memory = 512

  # Start with one task in dev to control Fargate costs.
  desired_count = 1

  # --------------------------------------------------------------------------
  # NETWORKING
  # --------------------------------------------------------------------------

  private_app_subnet_ids = module.vpc.private_app_subnet_ids

  ecs_security_group_id = module.security_groups.ecs_security_group_id

  # --------------------------------------------------------------------------
  # IAM
  # --------------------------------------------------------------------------

  execution_role_arn = module.iam.ecs_execution_role_arn

  task_role_arn = module.iam.ecs_task_role_arn

  # --------------------------------------------------------------------------
  # CLOUDWATCH
  # --------------------------------------------------------------------------

  log_group_name = module.cloudwatch.log_group_name

  # --------------------------------------------------------------------------
  # DATABASE SECRET
  # --------------------------------------------------------------------------

  database_secret_arn = module.rds.master_user_secret_arn

  # --------------------------------------------------------------------------
  # LOAD BALANCER
  # --------------------------------------------------------------------------
  # Leave this null for the moment.
  #
  # Once we create the ALB module, we will pass:
  #
  # module.alb.target_group_arn
  #
  # into this variable.
  target_group_arn = null

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
