# ==============================================================================
# RDS SUBNET GROUP
# ==============================================================================
# The DB subnet group tells Amazon RDS which subnets it is allowed to use for
# the PostgreSQL database.
#
# Only private database subnets are supplied here.
#
# The database therefore remains separated from the public/application tiers.
# ==============================================================================

resource "aws_db_subnet_group" "this" {
  name = "${var.project_name}-${var.environment}-db-subnet-group"

  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}


# ==============================================================================
# RDS POSTGRESQL INSTANCE
# ==============================================================================
# This creates the PostgreSQL database used by LaunchPad API.
#
# Important security decisions:
#
# - publicly_accessible = false
#     The database does not receive a public IP address.
#
# - private DB subnet group
#     RDS is placed in the private database tier.
#
# - encryption enabled
#     Database storage is encrypted at rest.
#
# - deletion protection configurable
#     Dev can disable it to make terraform destroy practical.
#
# - automated backups enabled
#     Allows recovery from recent database states.
#
# - manage_master_user_password = true
#     RDS creates and manages the master password using AWS Secrets Manager.
# ==============================================================================

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  storage_encrypted = true

  db_name  = var.database_name
  username = var.master_username
  port     = 5432

  # Let RDS generate and manage the master password in AWS Secrets Manager.
  manage_master_user_password = true

  # Keep the database private.
  publicly_accessible = false

  # Place RDS only in the private database subnets.
  db_subnet_group_name = aws_db_subnet_group.this.name

  # Only the RDS security group is attached here.
  vpc_security_group_ids = [
    var.rds_security_group_id
  ]

  # Automated backup configuration.
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  # Maintenance configuration.
  maintenance_window = var.maintenance_window

  # Prevent accidental deletion in production.
  deletion_protection = var.deletion_protection

  # Development environments can be destroyed without requiring a final
  # database snapshot.
  skip_final_snapshot = var.skip_final_snapshot

  # Apply configuration changes during the next maintenance window rather
  # than immediately where possible.
  apply_immediately = var.apply_immediately

  # Enable automatic minor version upgrades.
  auto_minor_version_upgrade = true

  # Copy tags to automated snapshots where supported.
  copy_tags_to_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-postgres"
  })
}
