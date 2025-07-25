data "aws_caller_identity" "current" {}

# tflint-ignore: terraform_unused_declarations
data "aws_region" "current" {}

resource "aws_kms_key" "key" {
  description              = var.description
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  policy                   = var.policy == null ? data.aws_iam_policy_document.kms.json : var.policy
  is_enabled               = var.is_enabled
  tags                     = var.tags
}

resource "aws_kms_alias" "alias" {
  name          = format("alias/%v", var.alias)
  target_key_id = aws_kms_key.key.key_id
}

data "aws_iam_policy_document" "kms" {

  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id),
      ]
    }
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.administrators) == 0 ? [] : [1]
    content {
      sid    = "AllowAccessForKeyAdministratorsAndKeyRoles"
      effect = "Allow"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
      ]
      principals {
        type        = "AWS"
        identifiers = var.administrators
      }
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.users) == 0 ? [] : [1]
    content {
      sid    = "AllowUseOfTheKeyByUsersOrRoles"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      principals {
        type        = "AWS"
        identifiers = var.users
      }
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.principals) == 0 ? [] : [1]
    content {
      sid    = "AllowAttachmentOfPersistentResources"
      effect = "Allow"
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]
      principals {
        type        = "AWS"
        identifiers = var.principals
      }
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
      resources = ["*"]
    }
  }
}
