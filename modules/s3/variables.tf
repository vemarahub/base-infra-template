variable "bucket_acl" {
  description = "(Optional) Bucket ACL. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, log-delivery-write. For more details https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl. Defaults to private"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public-read", "public-read-write", "aws-exec-read", "authenticated-read", "log-delivery-write"], var.bucket_acl)
    error_message = "Invalid bucket ACL specified."
  }
}

variable "name" {
  description = "A unique name to be added to all the resources where possible"
  type        = string
}

variable "bucket_logging" {
  description = "(Optional) Enable bucket logging. Will store logs in another existing bucket. You must give the log-delivery group WRITE and READ_ACP permissions to the target bucket. i.e. true | false. Defaults to false"
  type        = bool
  default     = false
}

variable "bucket_key_enabled" {
  description = "(Optional) Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "acl" {
  description = "Enable acl for S3 Bucket"
  type        = bool
  default     = false
}

variable "control_object_ownership" {
  description = "Enable controlling object ownership"
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "logging_bucket_name" {
  description = "(Optional) Name of the existing bucket where the logs will be stored. Defaults to null"
  type        = string
  default     = null
}

variable "logging_bucket_prefix" {
  description = "(Optional) Prefix for all log object keys. i.e. logs/. Defaults to null"
  type        = string
  default     = null
}

variable "force_destroy_bucket" {
  description = "(Optional) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. Defaults to false"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ARN used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms. Defaults to null"
  type        = string
  default     = null
}

variable "lifecycle_enabled" {
  description = "(Optional) Specifies lifecycle rule status. Defaults to false"
  type        = bool
  default     = false
}

variable "lifecycle_rule_prefix" {
  description = "(Optional) Specifies lifecycle rule prefix. Refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#lifecycle_rule"
  type        = any
  default = [{
    id      = "rule-1"
    prefix  = null
    enabled = true
    expiration = {
      date                         = null
      days                         = 90
      expired_object_delete_marker = false
    }
    transition = [{
      date          = null
      days          = 30
      storage_class = "STANDARD_IA"
      }, {
      date          = null
      days          = 60
      storage_class = "GLACIER"
    }]
    noncurrent_version_expiration = {
      days = 90
    }
    noncurrent_version_transition = [{
      days          = 30
      storage_class = "STANDARD_IA"
      }, {
      days          = 60
      storage_class = "GLACIER"
    }]
  }]
}


variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms. Defaults to AES256"
  type        = string
  default     = "AES256"
}


variable "versioning" {
  description = "(Optional) Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket. Defaults to false"
  type        = string
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning)
    error_message = "Invalid versioning option specified."
  }
}

variable "website" {
  description = "(Optional) Whether the bucket is used to host a website. Defaults to false"
  type        = bool
  default     = false
}

variable "website_error" {
  description = "(Optional) An absolute path to the document to return in case of a 4XX error. Defaults to error.html"
  type        = string
  default     = "error.html"
}

variable "website_index" {
  description = "(Optional) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders. Defaults to index.html"
  type        = string
  default     = "index.html"
}


variable "routing_rules" {
  description = "Optional, Conflicts with redirect_all_requests_to and routing_rules) List of rules that define when a redirect is applied and the redirect behavior. Refer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration#routing_rule"
  type = list(object({
    key_prefix_equals               = string
    http_error_code_returned_equals = string
    host_name                       = string
    http_redirect_code              = string
    protocol                        = string
    replace_key_prefix_with         = string
    replace_key_with                = string
  }))
  default = []
}

variable "redirect_all_request_to" {
  description = "(Optional, Required if index_document is not specified) The redirect behavior for every request to this bucket's website endpoint detailed below. Conflicts with error_document, index_document, and routing_rule."
  type = list(object({
    host_name = string
    protocol  = string
  }))
  default = []
}

variable "cors_configuration" {
  description = "(Required) Set of origins and methods (cross-origin access that you want to allow) documented below. You can configure up to 100 rules."
  type = list(object({
    id              = string
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = []

}

variable "public_access_configuration" {
  description = "(Optional) Manages S3 bucket-level Public Access Block configuration"
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "tags" {
  description = "A map of tags to be added to all the resources"
  type        = map(string)
  default     = {}
}
