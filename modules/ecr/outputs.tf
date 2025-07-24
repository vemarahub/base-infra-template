output "registry_id" {
  description = "ECR Registry ID"
  value       = aws_ecr_repository.ecr_repository.registry_id
}

output "registry_url" {
  description = "ECR Registry URL"
  value       = aws_ecr_repository.ecr_repository.repository_url
}

output "repository_name" {
  description = "ECR Registry name"
  value       = aws_ecr_repository.ecr_repository.name
}

output "repository_arn" {
  description = "ECR Registry ARN"
  value       = aws_ecr_repository.ecr_repository.arn
}
