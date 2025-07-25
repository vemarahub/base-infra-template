data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "hw_s3_bucket_kms_key_policy" {
  statement {
    sid    = "IAMUserPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "hw_s3_bucket_kms_key" {
  source      = "../modules/kms"
  alias       = format("%s-s3-bucket-kms-key", var.company_name)
  description = "Key used to encrypt S3 bucket's resources"
  policy      = data.aws_iam_policy_document.hw_s3_bucket_kms_key_policy.json
  tags        = local.tags
}
