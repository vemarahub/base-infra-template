output "db_cluster" {
  description = "The RDS cluster identifier"
  value       = compact(concat(aws_rds_cluster.db_cluster.*.id, ["None"]))[0]
}

output "db_instances" {
  description = "The DB instance identifier"
  value       = coalesce(concat(aws_rds_cluster_instance.cluster_instance.*.id, aws_db_instance.db_instance.*.id, ["None"]))[0]
}

output "db_endpoint" {
  description = "The RDS cluster endpoint"
  value       = compact(concat(aws_rds_cluster.db_cluster.*.endpoint, aws_db_instance.db_instance.*.address, ["None"]))[0]
}

output "db_reader_endpoint" {
  description = "The RDS cluster reader endpoint"
  value       = compact(concat(aws_rds_cluster.db_cluster.*.reader_endpoint, ["None"]))[0]
}

output "db_port" {
  description = "The RDS cluster db port"
  value       = coalesce(concat(aws_rds_cluster.db_cluster.*.port, aws_db_instance.db_instance.*.port, ["None"]))[0]
}

output "db_name" {
  description = "The RDS cluster db name"
  value       = coalesce(concat(aws_rds_cluster.db_cluster.*.database_name, aws_db_instance.db_instance.*.name, ["None"]))[0]
}

output "db_user" {
  description = "The RDS cluster master username"
  value       = coalesce(concat(aws_rds_cluster.db_cluster.*.master_username, aws_db_instance.db_instance.*.username, ["None"]))[0]
}

output "db_security_groups" {
  description = "The RDS cluster db security group"
  value       = aws_security_group.db_security_group.id
}
