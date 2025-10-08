resource "aws_db_subnet_group" "db_subnet_group" {
  count       = var.existing_subnet_group == null ? 1 : 0
  name_prefix = format("%s-", var.dbname)
  description = format("Database subnet group for %s", var.dbname)
  subnet_ids  = var.subnets
  tags        = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  count       = !local.mssql_engine && var.existing_parameter_group_name == null ? 1 : 0
  name_prefix = format("%s-", var.dbname)
  description = format("Database parameter group for %s", var.dbname)
  family      = var.family

  tags = local.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_option_group" "db_option_group" {
  count                    = var.existing_option_group_name == null ? 1 : 0
  name_prefix              = format("%s-", var.dbname)
  option_group_description = format("Option group for %s", var.dbname)
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version
  dynamic "option" {
    for_each = var.db_options
    content {
      option_name = option.value.option_name
      dynamic "option_settings" {
        for_each = lookup(option.value, "option_setting", [])
        content {
          name  = lookup(option_settings.value, "name", null)
          value = lookup(option_settings.value, "value", null)
        }
      }
    }
  }
  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
  timeouts {
    delete = lookup(var.option_group_timeouts, "delete", null)
  }
}

resource "aws_rds_cluster_parameter_group" "db_cluster_parameter_group" {
  count       = !local.mssql_engine && var.existing_cluster_parameter_group_name == null ? 1 : 0
  name_prefix = format("%s-", var.dbname)
  description = format("Cluster parameter group for %s", var.dbname)
  family      = var.family
  dynamic "parameter" {
    for_each = var.update_cluster_parameter_group
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method

    }
  }
  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "db_cluster" {
  count                           = !local.mssql_engine ? 1 : 0
  cluster_identifier              = var.dbname
  global_cluster_identifier       = local.global_cluster_identifier
  engine                          = var.engine
  engine_version                  = local.is_serverless ? null : var.engine_version
  port                            = var.port
  engine_mode                     = local.is_serverless ? local.serverless_engine_mode : var.engine_mode
  availability_zones              = var.availability_zones
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_id
  database_name                   = replace(var.dbname, "-", "")
  master_username                 = var.username
  master_password                 = var.password
  replication_source_identifier   = local.read_replica ? local.source_cluster_arn : null
  source_region                   = local.read_replica ? var.source_region : null
  snapshot_identifier             = var.db_snapshot_arn
  deletion_protection             = var.enable_delete_protection
  vpc_security_group_ids          = [aws_security_group.db_security_group.id]
  db_subnet_group_name            = local.subnet_group
  db_cluster_parameter_group_name = local.cluster_parameter_group
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.backup_window
  backtrack_window                = var.backtrack_window
  ca_certificate_identifier       = var.multi_az ? var.ca_cert_identifier : null
  preferred_maintenance_window    = var.maintenance_window
  skip_final_snapshot             = local.read_replica || var.skip_final_snapshot
  final_snapshot_identifier       = format("%s-final-snapshot", var.dbname)
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
  dynamic "scaling_configuration" {
    for_each = var.enable_serverless_v1 ? [var.scaling_configuration] : []
    content {
      auto_pause               = scaling_configuration.value.auto_pause
      max_capacity             = scaling_configuration.value.max_capacity
      min_capacity             = scaling_configuration.value.min_capacity
      seconds_until_auto_pause = scaling_configuration.value.seconds_until_auto_pause
      timeout_action           = scaling_configuration.value.timeout_action
    }
  }
  # Enable this when we add support for aws provider 4.x - Requires 4.12.0
  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.enable_serverless_v2 ? [var.serverlessv2_scaling_configuration] : []
    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }
  tags = local.tags

  # Option Group, Parameter Group, and Subnet Group and cluster parameter group added as the coalesce
  # to use any existing groups seems to throw off dependancies while destroying resources.
  depends_on = [
    aws_db_parameter_group.db_parameter_group,
    aws_db_option_group.db_option_group,
    aws_db_subnet_group.db_subnet_group,
    aws_rds_cluster_parameter_group.db_cluster_parameter_group,
  ]
}

# RDS Instances

resource "aws_rds_cluster_instance" "cluster_instance" {
  count             = !local.mssql_engine && !local.is_serverless ? var.replica_instances + 1 : 0
  identifier_prefix = format("%s-%02d", var.dbname, count.index + 1)

  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  cluster_identifier              = join("", aws_rds_cluster.db_cluster.*.id)
  promotion_tier                  = count.index
  db_subnet_group_name            = local.subnet_group
  db_parameter_group_name         = local.parameter_group
  performance_insights_enabled    = var.performance_insights_enable
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  monitoring_role_arn             = local.monitoring_role_arn
  monitoring_interval             = var.monitoring_interval
  apply_immediately               = var.apply_immediately
  tags                            = local.tags
  depends_on                      = [aws_rds_cluster.db_cluster]
}

resource "aws_db_instance" "db_instance" {
  count                       = local.mssql_engine ? 1 : 0
  identifier                  = format("%s-%02d", var.dbname, count.index + 1)
  db_name                     = local.mssql_engine ? null : var.dbname
  username                    = var.username
  password                    = var.password
  port                        = var.port
  engine                      = var.engine
  engine_version              = var.engine_version
  availability_zone           = var.multi_az ? null : local.db_instance_az
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_encrypted           = var.db_instance_storage_encrypted
  kms_key_id                  = var.kms_key_id
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  monitoring_role_arn         = local.monitoring_role_arn
  monitoring_interval         = var.monitoring_interval
  allow_major_version_upgrade = var.allow_major_version_upgrade
  vpc_security_group_ids = compact(
    concat(
      [join("", aws_security_group.db_security_group.*.id)],
      var.existing_security_group_ids
    )
  )

  db_subnet_group_name                  = local.subnet_group
  parameter_group_name                  = local.parameter_group
  option_group_name                     = aws_db_option_group.db_option_group[count.index].name
  license_model                         = var.license_model
  multi_az                              = var.multi_az
  storage_type                          = var.storage_type
  iops                                  = var.storage_type == "io1" ? var.iops_value : null
  maintenance_window                    = var.maintenance_window
  backup_retention_period               = var.backup_retention_period
  backup_window                         = var.backup_window
  final_snapshot_identifier             = format("%s-final-snapshot", var.dbname)
  tags                                  = local.tags
  deletion_protection                   = var.enable_delete_protection
  skip_final_snapshot                   = var.skip_final_snapshot
  performance_insights_enabled          = var.performance_insights_enable
  performance_insights_kms_key_id       = var.performance_insights_enable ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enable ? var.performance_insights_retention_period : null
  depends_on = [
    aws_db_parameter_group.db_parameter_group,
    aws_db_option_group.db_option_group,
    aws_db_subnet_group.db_subnet_group,
  ]
  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    update = var.timeouts.update
  }
}
