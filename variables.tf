variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-app"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for sanitized names and dynamic AZs
locals {
  # Sanitize project name for AWS resources that have strict naming requirements
  sanitized_project_name = lower(replace(replace(var.project_name, "/[^a-zA-Z0-9-]/", "-"), "/--+/", "-"))
  
  # Remove leading/trailing hyphens
  clean_project_name = trim(local.sanitized_project_name, "-")
  
  # Use provided AZs or auto-discover (take first 2 available)
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones (leave empty to auto-discover)"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Route53 Configuration
variable "domain_name" {
  description = "Domain name for Route53 (leave empty to skip DNS setup)"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain for the application (optional)"
  type        = string
  default     = ""
}

# API Gateway Configuration
variable "api_domain_name" {
  description = "Custom domain name for API Gateway (optional)"
  type        = string
  default     = ""
}

variable "existing_certificate_arn" {
  description = "ARN of existing ACM certificate (if not using Route53 managed certificate)"
  type        = string
  default     = ""
}

# CloudFront Configuration
variable "cloudfront_aliases" {
  description = "List of domain aliases for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_domain_name" {
  description = "Custom domain name for CloudFront distribution (optional)"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200",
      "PriceClass_100"
    ], var.cloudfront_price_class)
    error_message = "CloudFront price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}
