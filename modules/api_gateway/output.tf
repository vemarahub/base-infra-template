output "rest_api_id" {
  description = "ID of the REST API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_execution_arn" {
  description = "Execution ARN of the REST API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.main.id
}

output "invoke_url" {
  description = "Invoke URL for the API Gateway"
  value       = "${aws_api_gateway_deployment.main.invoke_url}"
}

output "stage_name" {
  description = "Stage name of the API Gateway deployment"
  value       = var.environment
}

output "domain_name" {
  description = "Domain name of the API Gateway custom domain"
  value       = var.api_domain_name != "" ? aws_api_gateway_domain_name.main[0].domain_name : null
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name of the API Gateway custom domain"
  value       = var.api_domain_name != "" ? aws_api_gateway_domain_name.main[0].cloudfront_domain_name : null
}

output "cloudfront_zone_id" {
  description = "CloudFront zone ID of the API Gateway custom domain"
  value       = var.api_domain_name != "" ? aws_api_gateway_domain_name.main[0].cloudfront_zone_id : null
}