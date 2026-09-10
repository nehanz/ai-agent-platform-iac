output "platform_kms_key_arn" {
  description = "ARN of the platform control-plane KMS key"
  value       = module.platform_kms.key_arn
}

output "platform_kms_key_alias" {
  description = "Alias name of the platform KMS key"
  value       = module.platform_kms.key_alias_name
}

output "tenant_ref_kms_key_arn" {
  description = "ARN of the reference tenant KMS key"
  value       = module.tenant_ref_kms.key_arn
}

output "tenant_ref_kms_key_alias" {
  description = "Alias name of the reference tenant KMS key"
  value       = module.tenant_ref_kms.key_alias_name
}

output "tenant_ref_tool_secret_arn" {
  description = "ARN of the reference tenant tool secret"
  value       = module.tenant_ref_tool_secret.secret_arn
}

output "tenant_ref_tool_secret_name" {
  description = "Hierarchical path name of the reference tenant tool secret"
  value       = module.tenant_ref_tool_secret.secret_name
}

output "audit_bucket_name" {
  description = "The globally unique name of the S3 audit bucket"
  value       = module.audit_bucket.bucket_name
}

output "audit_bucket_arn" {
  description = "The ARN of the S3 audit bucket"
  value       = module.audit_bucket.bucket_arn
}
