data "aws_iam_policy_document" "enhanced_monitoring" {
  count = local.monitoring_count
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count              = local.monitoring_count
  name               = format("%s-monitoring-role", var.dbname)
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring[count.index].json
  description        = format("enhanced monitoring for %s", var.dbname)
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count      = local.monitoring_count
  role       = aws_iam_role.enhanced_monitoring[count.index].name
  policy_arn = format("arn:%s:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole", data.aws_partition.current.partition)
}
