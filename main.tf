terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  clean_project_name = lower(replace(var.project_name, "/[^a-zA-Z0-9]/", ""))
  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name        = local.clean_project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = local.availability_zones
  tags                = local.common_tags
}

# Security and Load Balancer Module
module "security" {
  source = "./modules/security"

  project_name      = local.clean_project_name
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnets
  tags              = local.common_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project_name          = local.clean_project_name
  vpc_id                = module.networking.vpc_id
  alb_security_group_id = module.security.alb_security_group_id
  log_retention_days    = 7
  tags                  = local.common_tags
  enable_container_insights = true
  container_ports       = [80, 443]
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api_gateway"

  project_name      = local.clean_project_name
  environment       = var.environment
  load_balancer_dns = module.security.alb_dns_name
  api_domain_name   = var.api_domain_name
  certificate_arn   = var.domain_name != "" ? aws_acm_certificate_validation.main[0].certificate_arn : var.existing_certificate_arn
  tags              = local.common_tags
}

# CloudFront Module
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name          = local.clean_project_name
  environment           = var.environment
  aws_region            = var.aws_region
  load_balancer_dns     = module.security.alb_dns_name
  api_gateway_id        = module.api_gateway.rest_api_id
  cloudfront_aliases    = var.cloudfront_aliases
  cloudfront_price_class = var.cloudfront_price_class
  certificate_arn       = var.domain_name != "" ? aws_acm_certificate_validation.main[0].certificate_arn : var.existing_certificate_arn
  tags                  = local.common_tags
}

# ACM Certificate (if domain name is provided)
resource "aws_acm_certificate" "main" {
  count = var.domain_name != "" ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = concat([var.cloudfront_domain_name], var.api_domain_name != "" ? [var.api_domain_name] : [])
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

# Route53 Zone
resource "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name

  tags = local.common_tags
}

# Certificate Validation Records
resource "aws_route53_record" "cert_validation" {
  for_each = var.domain_name != "" ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main[0].zone_id
}

# Certificate Validation
resource "aws_acm_certificate_validation" "main" {
  count = var.domain_name != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Route53 Record for CloudFront
resource "aws_route53_record" "cloudfront" {
  count   = var.domain_name != "" && var.cloudfront_domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.cloudfront_domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront.distribution_domain_name
    zone_id                = module.cloudfront.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 Record for API Gateway
resource "aws_route53_record" "api" {
  count   = var.api_domain_name != "" && var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.api_domain_name
  type    = "A"

  alias {
    name                   = module.api_gateway.cloudfront_domain_name
    zone_id                = module.api_gateway.cloudfront_zone_id
    evaluate_target_health = true
  }
}