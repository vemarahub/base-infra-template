# variables.tf (root)

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., prod, dev)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
  default     = ""
}

variable "api_domain_name" {
  description = "The domain name for API Gateway"
  type        = string
  default     = ""
}

variable "cloudfront_domain_name" {
  description = "The domain name for CloudFront"
  type        = string
  default     = ""
}

variable "existing_certificate_arn" {
  description = "ARN of an existing ACM certificate"
  type        = string
  default     = ""
}

variable "cloudfront_aliases" {
  description = "List of aliases for CloudFront"
  type        = list(string)
  default     = []
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}