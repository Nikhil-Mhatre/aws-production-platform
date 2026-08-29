# ==============================================================================
# APPLICATION LOAD BALANCER (ALB) SECURITY GROUP
# This acts as the "front door" for external user traffic.
# ==============================================================================
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  # Ingress rules control INBOUND traffic.
  # We open port 80 (HTTP) to the entire internet (0.0.0.0/0).
  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # We also open port 443 (HTTPS) to the entire internet for secure web traffic.
  ingress {
    description = "HTTPS from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules control OUTBOUND traffic.
  # We allow the ALB to send traffic out to anywhere (0.0.0.0/0).
  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Note: "-1" means all protocols.
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# ECS FARGATE TASKS SECURITY GROUP
# This protects our actual application servers (containers).
# ==============================================================================
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = var.vpc_id

  # SECURITY GROUP CHAINING: Notice we don't use CIDR blocks here!
  # Instead, we only accept traffic coming from the ALB's security group.
  # This ensures nobody can bypass the Load Balancer to talk directly to the app.
  ingress {
    description     = "Application traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allows the application containers to reach out to the internet
  # (e.g., to fetch software updates or talk to external APIs).
  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# RDS (DATABASE) SECURITY GROUP
# This provides the strictest level of access for our database layer.
# ==============================================================================
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  # Further Security Group Chaining: We only allow PostgreSQL traffic (port 5432)
  # strictly from the ECS tasks. The database cannot be reached directly
  # from the ALB or the public internet.
  ingress {
    description     = "PostgreSQL traffic from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  # Note for juniors: Because there is no 'egress' block defined here, Terraform
  # will remove all outbound rules upon creation by default, locking down the
  # database from initiating any external connections.

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
