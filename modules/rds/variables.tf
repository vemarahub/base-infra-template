variable "workspaces_enabled" {
  type        = bool
  description = "Whether terraform workspaces are enabled"
  default     = true
}

variable "environment_name" {
  type        = string
  description = "Logical name of the environment where the module is deployed"
  default     = null
}

/* VPC Configuration */
variable "vpc_id" {
  description = "VPC ID where RDS to be created"
  type        = string
}

variable "existing_subnet_group" {
  description = "Existing DB subnet group to be used for this cluster (OPTIONAL)"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "A list of associated security group IDS. Defaults to []"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use for RDS ingress rules "
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
}

/* Basic RDS */

variable "dbname" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
}
#https://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html

variable "engine" {
  description = "Database Engine Type.  Allowed values: aurora-mysql, aurora, aurora-postgresql for RDS cluster. For mssql use sqlserver-ex/ee/web/ce-*"
  type        = string
}

variable "engine_version" {
  description = "Database Engine Minor Version http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html"
  type        = string
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with."
  type        = string
}


variable "engine_mode" {
  description = "The database engine mode. Allowed values: provisioned and global(aurora engine only)."
  type        = string
  default     = "provisioned"
}

variable "allow_major_version_upgrade" {
  description = "(Optional) Indicates that major version upgrades are allowed."
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "The instance class to use"
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
}

variable "global_cluster_identifier" {
  description = "Global Cluster identifier. Property of aws_rds_global_cluster (Ignored if engine_mode is not 'global')."
  type        = string
  default     = null
}

// Serverless

variable "enable_serverless_v1" {
  description = "set the engine mode as aurora-serverlessv1. Refer https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v1.how-it-works.html"
  type        = bool
  default     = false
}

variable "enable_serverless_v2" {
  description = "set the engine mode as aurora-serverlessv2. Refer https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html"
  type        = bool
  default     = false
}

variable "scaling_configuration" {
  description = "(Optional) Nested attribute with scaling properties. Only valid when engine_mode is set to serverless. Valid only for enable_serverless_v1"
  type = object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  })
  default = null

}

variable "serverlessv2_scaling_configuration" {
  description = "(Optional) Nested attribute with scaling properties for ServerlessV2. Only valid when engine_mode is set to provisioned."
  type = object({
    max_capacity = number
    min_capacity = number
  })
  default = null

}

/* MSSQL */

variable "db_options" {
  description = "options required for db_parameter group for MSSQL - https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.SQLServer.Options.html"
  type = list(object({
    option_name = string
    option_setting = list(object({
      name  = string
      value = string
    }))

  }))
  default = []

}

variable "license_model" {
  description = "License model for this DB. Optional, but required for some DB Engines. Valid values: license-included | bring-your-own-license | general-public-license"
  type        = string
  default     = "license-included"
}

variable "allocated_storage" {
  description = "The allocated storage in GBs"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling max allocated storage"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Set to true if multi AZ deployment must be supported"
  type        = bool
  default     = false
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  type        = string
  default     = "gp2"
}

variable "iops_value" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1' #https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS "
  type        = number
  default     = 1000
}

variable "db_instance_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "timeouts" {
  description = "(Optional) Updated Terraform resource management timeouts. Applies to `aws_db_instance` in particular to permit resource management times"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "50m"
    update = "80m"
    delete = "50m"
  }
}

variable "option_group_timeouts" {
  description = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type = object({
    delete = string
  })
  default = {
    delete = "15m"
  }
}

/* Authentication */

variable "password" {
  description = "Password for the master DB user"
  type        = string
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
  default     = "dbadmin"
}

/* Encryption */

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
  default     = null
}

/* Cluster */

variable "availability_zones" {
  description = "A list of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured"
  type        = list(string)
  default     = []
}

variable "source_cluster" {
  description = "The cluster ID of the master Aurora cluster that will replicate to the created cluster. The master must be in a different region. Leave this parameter blank to create a master Aurora cluster."
  type        = string
  default     = null
}

variable "source_region" {
  description = "The region of the master Aurora cluster that will replicate to the created cluster. The master must be in a different region. Leave this parameter blank to create a master Aurora cluster."
  type        = string
  default     = null
}

variable "enable_delete_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "replica_instances" {
  description = "The number of Aurora replica instances to create.  This can range from 0 to 15."
  type        = number
  default     = 0
}

variable "existing_cluster_parameter_group_name" {
  description = "Name of the existing cluster parameter group to associate"
  type        = string
  default     = null
}

variable "update_cluster_parameter_group" {
  description = "(Optional) A list of DB parameters to apply. Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-parameters after initial creation of the group."
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default = []

}

variable "existing_option_group_name" {
  description = "Name of the existing DB option group to associate"
  type        = string
  default     = null
}

variable "existing_parameter_group_name" {
  description = "Name of the existing DB parameter group to associate"
  type        = string
  default     = null
}

variable "existing_security_group_ids" {
  description = "The IDs of the existing security groups to associate with the DB instance"
  type        = list(string)
  default     = []
}

variable "family" {
  description = "Parameter Group Family Name (ex. aurora5.6, aurora-postgresql9.6, aurora-mysql5.7)"
  type        = string
}

/* Backup and Maintenance */

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = string
  default     = 35
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "05:00-06:00"
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for aurora engine currently"
  type        = number
  default     = 0
}

variable "db_snapshot_arn" {
  description = "Specifies whether or not to create this cluster from a snapshot."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted."
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "Sun:07:00-Sun:08:00"
}

variable "auto_minor_version_upgrade" {
  description = "(Optional) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false

}
/* Logging and Monitoring */

variable "cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`."
  type        = list(string)
  default     = []
}

variable "performance_insights_enable" {
  description = "Specifies whether Performance Insights are enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = " The ARN for the KMS key to encrypt Performance Insights data. When specifying performance_insights_kms_key_id, performance_insights_enabled needs to be set to true. Once KMS key is set, it can never be changed"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}
variable "alarm_cpu_threshold" {
  description = "The value against which the cpu statistic is compared."
  type        = number
  default     = 60
}

variable "alarm_burst_balance_threshold" {
  description = "The minimum percent of General Purpose SSD (gp2) burst-bucket I/O credits available."
  type        = number
  default     = null
}

variable "alarm_disk_queue_depth_threshold" {
  description = "The maximum number of outstanding IOs (read/write requests) waiting to access the disk."
  type        = number
  default     = null
}

variable "alarm_freeable_memory_threshold" {
  description = "The minimum amount of available random access memory in Byte."
  type        = number
  default     = null # 64000000 for 64 Megabyte in Byte
}

variable "alarm_free_storage_space_threshold" {
  description = "The minimum amount of available storage space in Byte."
  type        = number
  default     = null # 4000000000 for 4 Gigabyte in Byte
}

variable "swap_usage_threshold" {
  description = "The maximum amount of swap space used on the DB instance in Byte."
  type        = number
  default     = null # 256000000 for 256 Megabyte in Byte
}

variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)"
  type        = list(string)
  default     = []
}

/*Enhanced monitoring */

variable "create_monitoring_role" {
  description = "enable to create RDS enhanced monitoring IAM role"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "(Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "(Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  type        = string
  default     = null
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}
/* Other */

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
