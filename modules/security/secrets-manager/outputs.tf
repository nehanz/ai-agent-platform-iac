output "secret_id" {
  description = "The ID of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "The full hierarchical name/path of the secret"
  value       = aws_secretsmanager_secret.this.name
}

output "kms_key_arn" {
  description = "The KMS key ARN used for encrypting this secret"
  value       = aws_secretsmanager_secret.this.kms_key_id
}
