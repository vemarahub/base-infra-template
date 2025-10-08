resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  count               = !local.is_serverless ? var.replica_instances + 1 : 0
  alarm_name          = format("alarm-%s-DatabaseServerCPUUtilization-%s-%d", var.workspaces_enabled ? terraform.workspace : var.environment_name, var.dbname, count.index)
  alarm_description   = "Database server CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_cpu_threshold

  dimensions = {
    DBInstanceIdentifier = local.mssql_engine ? aws_db_instance.db_instance.*.id[count.index] : aws_rds_cluster_instance.cluster_instance.*.id[count.index]
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "burst_balance" {
  count               = var.alarm_burst_balance_threshold != null ? var.replica_instances + 1 : 0
  alarm_name          = format("alarm-%s-BurstBalance-%s-%d", var.workspaces_enabled ? terraform.workspace : var.environment_name, var.dbname, count.index)
  alarm_description   = "Average database storage burst balance over last 5 minutes too low, expect a significant performance drop soon"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_burst_balance_threshold

  dimensions = {
    DBInstanceIdentifier = local.mssql_engine ? aws_db_instance.db_instance.*.id[count.index] : aws_rds_cluster_instance.cluster_instance.*.id[count.index]
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  count               = var.alarm_disk_queue_depth_threshold != null ? var.replica_instances + 1 : 0
  alarm_name          = format("alarm-%s-DiskQueueDepth-%s-%d", var.workspaces_enabled ? terraform.workspace : var.environment_name, var.dbname, count.index)
  alarm_description   = "Average database disk queue depth over last 5 minutes too high, performance may suffer"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_disk_queue_depth_threshold

  dimensions = {
    DBInstanceIdentifier = local.mssql_engine ? aws_db_instance.db_instance.*.id[count.index] : aws_rds_cluster_instance.cluster_instance.*.id[count.index]
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  count               = var.alarm_freeable_memory_threshold != null ? var.replica_instances + 1 : 0
  alarm_name          = format("alarm-%s-FreeableMemory-%s-%d", var.workspaces_enabled ? terraform.workspace : var.environment_name, var.dbname, count.index)
  alarm_description   = "Average database freeable memory over last 5 minutes too low, performance may suffer"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_freeable_memory_threshold

  dimensions = {
    DBInstanceIdentifier = local.mssql_engine ? aws_db_instance.db_instance.*.id[count.index] : aws_rds_cluster_instance.cluster_instance.*.id[count.index]
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  count               = var.alarm_free_storage_space_threshold != null ? var.replica_instances + 1 : 0
  alarm_name          = format("alarm-%s-FreeStorageSpace-%s-%d", var.workspaces_enabled ? terraform.workspace : var.environment_name, var.dbname, count.index)
  alarm_description   = "Average database free storage space over last 5 minutes too low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_free_storage_space_threshold

  dimensions = {
    DBInstanceIdentifier = local.mssql_engine ? aws_db_instance.db_instance.*.id[count.index] : aws_rds_cluster_instance.cluster_instance.*.id[count.index]
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
}

resource "aws_cloudwatch_metric_alarm" "swap_usage_too_high" {
  count               = var.swap_usage_threshold != null ? var.replica_instances + 1 : 0
  alarm_name          = format("alarm-%s-SwapUsage-%s-%d", var.workspaces_enabled ? terraform.workspace : var.environment_name, var.dbname, count.index)
  alarm_description   = "Average database swap usage over last 5 minutes too high, performance may suffer"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.swap_usage_threshold

  dimensions = {
    DBInstanceIdentifier = local.mssql_engine ? aws_db_instance.db_instance.*.id[count.index] : aws_rds_cluster_instance.cluster_instance.*.id[count.index]
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
}
