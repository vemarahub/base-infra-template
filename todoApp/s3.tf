module "hw_access_logs_s3_bucket" {
  source     = "../modules/s3"
  name       = format("%s-s3-access-logs-bucket", var.department_name)
  bucket_acl = "log-delivery-write"
  tags       = local.tags
}

module "hw_todo_images_s3_bucket" {
  source                = "../modules/s3"
  name                  = format("%s-bucket", local.hw_todo_service_name)
  sse_algorithm         = "aws:kms"
  kms_master_key_id     = module.hw_s3_bucket_kms_key.key_arn
  bucket_logging        = true
  logging_bucket_name   = module.hw_access_logs_s3_bucket.bucket_name
  logging_bucket_prefix = format("%s/", local.hw_todo_service_name)
  tags                  = local.tags

  lifecycle_enabled = "true"
  lifecycle_rule_prefix = [
    {
      id      = "store-locator-export-backup"
      prefix  = format("hw-todoapp-images-backup/")
      enabled = true
      expiration = {
        date                         = null
        days                         = 90
        expired_object_delete_marker = false
      }
    }
  ]
}