output "policy_store_id" {
  description = "ID of the Verified Permissions policy store"
  value       = aws_verifiedpermissions_policy_store.this.id
}

output "policy_store_arn" {
  description = "ARN of the Verified Permissions policy store"
  value       = aws_verifiedpermissions_policy_store.this.arn
}

output "tenant_isolation_policy_id" {
  description = "ID of the Cedar tenant isolation policy"
  value       = aws_verifiedpermissions_policy.tenant_isolation_policy.policy_id
}
