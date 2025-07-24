resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  dynamic "encryption_configuration" {
    for_each = var.encryption_configuration == null ? [] : var.encryption_configuration
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key
    }
  }
  tags = var.tags
}

data "aws_iam_policy_document" "repository_cross_account_read_only_policy" {
  statement {
    sid    = "cross_account_read_policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.account_ids)
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:Describe*",
      "ecr:Get*",
      "inspector2:ListFindings",
      "inspector2:ListAccountPermissions",
      "inspector2:ListCoverage"
    ]
  }

  statement {
    sid    = "current_account_read_write_policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)]
    }
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:Describe*",
      "ecr:Get*",
      "inspector2:ListFindings",
      "inspector2:ListAccountPermissions",
      "inspector2:ListCoverage"

    ]
  }
  statement {
    sid    = "LambdaECRImageCrossAccountRetrievalPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      values   = formatlist("arn:aws:lambda:*:%s:function:*", concat(var.account_ids, [data.aws_caller_identity.current.account_id]))
      variable = "aws:sourceArn"
    }
  }

  statement {
    sid    = "EMRServerlessImageCrossAccountRetrievalPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer"
    ]
    principals {
      type        = "Service"
      identifiers = ["emr-serverless.amazonaws.com"]
    }
  }

}

data "aws_iam_policy_document" "repository_cross_account_read_write_policy" {
  statement {
    sid    = "current_account_read_write_policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", concat(var.account_ids, [data.aws_caller_identity.current.account_id]))
    }
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:ListImages",
      "inspector2:ListFindings",
      "inspector2:ListAccountPermissions",
      "inspector2:ListCoverage"
    ]
  }

  statement {
    sid    = "LambdaECRImageCrossAccountRetrievalPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      values   = formatlist("arn:aws:lambda:*:%s:function:*", concat(var.account_ids, [data.aws_caller_identity.current.account_id]))
      variable = "aws:sourceArn"
    }
  }
}

resource "aws_ecr_repository_policy" "repository_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = var.enable_crossaccount_write_access ? data.aws_iam_policy_document.repository_cross_account_read_write_policy.json : data.aws_iam_policy_document.repository_cross_account_read_only_policy.json
}


resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy = templatefile(format("%s/templates/lifecycle_policy.json", path.module), {
    max_image_count        = var.lifecycle_max_image_count
    tag_status             = var.lifecycle_tag_status
    ecr_tag_prefixes       = var.ecr_tag_prefixes
    tagged_image_max_count = var.lifecycle_tagged_image_max_count
  })
}
