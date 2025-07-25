output "alias_name" {
  description = "The display name of the alias"
  value       = aws_kms_alias.alias.name
}

output "alias_arn" {
  description = "The Amazon Resource Name(ARN) of the key alias"
  value       = aws_kms_alias.alias.arn
}

output "key_id" {
  description = "The globally unique identifier for the key."
  value       = aws_kms_key.key.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key."
  value       = aws_kms_key.key.arn
}
