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
