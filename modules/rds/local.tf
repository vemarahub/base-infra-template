locals {
  mssql_engine              = length(regexall("^sqlserver{1,9}", var.engine)) > 0 ? true : false
  is_serverless             = var.enable_serverless_v1 || var.enable_serverless_v2
  serverless_engine_mode    = local.is_serverless && var.scaling_configuration != null ? "serverless" : "provisioned"
  global_cluster_identifier = var.engine_mode == "global" ? var.global_cluster_identifier : null
  read_replica              = var.source_cluster != null && var.source_region != null
  source_cluster_arn        = local.read_replica ? format("arn:aws:rds:%s:%s:cluster:%s", var.source_region, data.aws_caller_identity.current.account_id, var.source_cluster) : null
  subnet_group              = coalesce(var.existing_subnet_group, join("", aws_db_subnet_group.db_subnet_group.*.id))
  parameter_group           = !local.mssql_engine ? coalesce(var.existing_parameter_group_name, join("", aws_db_parameter_group.db_parameter_group.*.id)) : null
  cluster_parameter_group   = !local.mssql_engine ? coalesce(var.existing_cluster_parameter_group_name, join("", aws_rds_cluster_parameter_group.db_cluster_parameter_group.*.id)) : null
  db_instance_az            = coalesce(var.availability_zones)[0]
  monitoring_role_arn       = (var.create_monitoring_role && var.monitoring_role_arn == null) ? aws_iam_role.enhanced_monitoring[0].arn : var.monitoring_role_arn
  monitoring_count          = var.create_monitoring_role ? 1 : 0
  tags                      = merge(var.tags, { Name : var.dbname })
}
