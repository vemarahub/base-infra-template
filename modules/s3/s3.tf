locals {
  additional_tags = {
    "LoggingEnabled"           = var.bucket_logging
    "VersioningEnabled"        = var.versioning == "Enabled" ? true : false
    "BlockPublicAccessEnabled" = (var.public_access_configuration.block_public_acls && var.public_access_configuration.block_public_policy && var.public_access_configuration.ignore_public_acls && var.public_access_configuration.restrict_public_buckets)
  }
  current_account_logging_bucket = "hellowereld-${data.aws_caller_identity.current.account_id}-s3-logging-bucket"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.name
  tags          = merge(var.tags, local.additional_tags)
  force_destroy = var.force_destroy_bucket
}

resource "aws_s3_bucket_acl" "s3_acl" {
  count  = var.acl ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = var.bucket_acl
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = var.control_object_ownership ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = var.object_ownership
  }

  depends_on = [
    aws_s3_bucket_public_access_block.s3_bucket_public_access_block,
    aws_s3_bucket.s3_bucket
  ]
}

resource "aws_s3_bucket_website_configuration" "s3_website" {
  count  = var.website ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id
  index_document {
    suffix = var.website_index
  }
  error_document {
    key = var.website_error
  }
  dynamic "routing_rule" {
    for_each = var.routing_rules
    content {
      condition {
        key_prefix_equals               = routing_rule.value.key_prefix_equals
        http_error_code_returned_equals = routing_rule.value.http_error_code_returned_equals
      }
      redirect {
        host_name               = routing_rule.value.redirect_hostname
        http_redirect_code      = routing_rule.value.redirect_http_redirect_code
        protocol                = routing_rule.value.redirect_protocol
        replace_key_prefix_with = routing_rule.value.redirect_replace_key_prefix_with
        replace_key_with        = routing_rule.value.redirect_replace_key_with
      }
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_index == null ? var.redirect_all_request_to : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol

    }
  }
}

resource "aws_s3_bucket_logging" "s3_bucket_logging" {
  count         = var.bucket_logging ? 1 : 0
  bucket        = aws_s3_bucket.s3_bucket.id
  target_bucket = coalesce(var.logging_bucket_name, local.current_account_logging_bucket)
  target_prefix = coalesce(var.logging_bucket_prefix, aws_s3_bucket.s3_bucket.id)
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_cors_configuration" "s3_bucket_cors" {
  count  = length(var.cors_configuration) > 0 ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id
  dynamic "cors_rule" {
    for_each = var.cors_configuration
    content {
      id              = cors_rule.value.id
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    bucket_key_enabled = var.bucket_key_enabled
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id
  dynamic "rule" {
    for_each = var.lifecycle_rule_prefix

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", "Enabled")

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }

      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          noncurrent_days = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          noncurrent_days = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "filter" {
        for_each = try(flatten([rule.value.filter]), [])
        content {
          prefix = try(filter.value.prefix, null)
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.s3_bucket_versioning]
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = var.public_access_configuration.block_public_acls
  block_public_policy     = var.public_access_configuration.block_public_policy
  ignore_public_acls      = var.public_access_configuration.ignore_public_acls
  restrict_public_buckets = var.public_access_configuration.restrict_public_buckets
}
