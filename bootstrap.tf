# Bootstrap resources for Terraform state management
# These resources need to be created before configuring the S3 backend
# COMMENTED OUT: These resources are created by the bootstrap script


# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${local.clean_project_name}-${var.environment}-${random_string.state_suffix.result}"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "random_string" "state_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  count          = var.create_dynamodb_table ? 1 : 0
  name           = "terraform-state-lock-${local.clean_project_name}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  lifecycle {
    prevent_destroy = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
    Project     = var.project_name
  }
}

