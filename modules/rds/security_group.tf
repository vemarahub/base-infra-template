resource "aws_security_group" "db_security_group" {
  name        = format("%s-rds-sg", var.dbname)
  description = format("%s DB cluster security group", var.dbname)
  vpc_id      = var.vpc_id
  lifecycle {
    ignore_changes = [description]
  }
  tags = merge(var.tags, { Name : var.dbname })
}

resource "aws_security_group_rule" "ingress_sg" {
  count                    = length(var.security_groups)
  from_port                = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  source_security_group_id = length(var.security_groups) > 0 ? var.security_groups[count.index] : null
  to_port                  = var.port
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each          = toset(var.allowed_cidr_blocks)
  from_port         = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.db_security_group.id
  cidr_blocks       = [each.value]
  to_port           = var.port
  type              = "ingress"
}

resource "aws_security_group_rule" "egress_sg" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db_security_group.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
