# ==============================================================================
# ECS CLUSTER
# ==============================================================================
# The ECS cluster provides the logical grouping for our LaunchPad API
# workloads.
#
# We use the Fargate launch type, which means AWS manages the underlying
# container hosts for us.
# ==============================================================================

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-cluster"
  })
}


# ==============================================================================
# ECS TASK DEFINITION
# ==============================================================================
# Defines how the LaunchPad API container should run.
#
# The task definition specifies:
#
# - Docker image
# - CPU and memory
# - Container port
# - IAM roles
# - CloudWatch logging
# - Database secret injection
#
# The application itself remains stateless. Persistent data belongs in RDS.
# ==============================================================================

resource "aws_ecs_task_definition" "this" {
  family = "${var.project_name}-${var.environment}"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name = var.container_name

      image = var.container_image

      essential = true

      portMappings = [
        {
          name          = "http"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.node_environment
        },

        {
          name  = "PORT"
          value = tostring(var.container_port)
        },

        {
          name  = "DB_HOST"
          value = var.database_host
        },

        {
          name  = "DB_NAME"
          value = var.database_name
        },
        {
          name  = "DB_SSL"
          value = "true"
        }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${var.database_secret_arn}:username::"
        },

        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.database_secret_arn}:password::"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "node -e \"require('http').get('http://localhost:${var.container_port}/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))\""
        ]

        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "launchpad"
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-task-definition"
  })
}


# ==============================================================================
# ECS SERVICE
# ==============================================================================
# Maintains the desired number of LaunchPad API tasks.
#
# The service will later be connected to the Application Load Balancer through
# the target_group_arn variable.
#
# ECS automatically replaces tasks that become unhealthy or stop unexpectedly.
# ==============================================================================

resource "aws_ecs_service" "this" {
  name = "${var.project_name}-${var.environment}"

  cluster = aws_ecs_cluster.this.id

  task_definition = aws_ecs_task_definition.this.arn

  desired_count = var.desired_count

  launch_type = "FARGATE"

  platform_version = "LATEST"

  network_configuration {
    subnets = var.private_app_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    # ECS tasks remain private. Public IP addresses are not assigned.
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  # Prevent Terraform from unnecessarily replacing the service when ECS
  # performs an independent deployment.
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  # --------------------------------------------------------------------------
  # LOAD BALANCER
  # --------------------------------------------------------------------------
  # The target group ARN is optional at this stage because the ALB module will
  # be created separately.
  #
  # Once the ALB exists, this block connects ECS tasks to the target group.
  # --------------------------------------------------------------------------

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-service"
  })
}
