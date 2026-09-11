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

output "tenant_registry_table_name" {
  description = "Name of the tenant registry DynamoDB table"
  value       = module.tenant_registry_table.table_name
}

output "agent_sessions_table_name" {
  description = "Name of the agent sessions DynamoDB table"
  value       = module.agent_sessions_table.table_name
}

output "tenant_budgets_table_name" {
  description = "Name of the tenant budgets DynamoDB table"
  value       = module.tenant_budgets_table.table_name
}

output "agent_task_queue_url" {
  description = "URL of the main agent task SQS FIFO queue"
  value       = module.agent_task_queue.queue_id
}

output "agent_task_queue_arn" {
  description = "ARN of the main agent task SQS FIFO queue"
  value       = module.agent_task_queue.queue_arn
}

output "agent_task_dlq_arn" {
  description = "ARN of the agent task Dead Letter Queue"
  value       = module.agent_task_queue.dlq_arn
}
