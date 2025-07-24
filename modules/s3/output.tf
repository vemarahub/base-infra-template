output "bucket_name" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.s3_bucket.bucket
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}

output "bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = aws_s3_bucket_website_configuration.s3_website[*].website_endpoint
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records."
  value       = aws_s3_bucket_website_configuration.s3_website[*].website_domain
}
