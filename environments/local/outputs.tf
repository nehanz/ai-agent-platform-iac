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

output "agent_runner_lambda_arn" {
  description = "ARN of the Agent Runner Lambda function"
  value       = module.agent_runner_lambda.function_arn
}

output "agent_runner_lambda_name" {
  description = "Name of the Agent Runner Lambda function"
  value       = module.agent_runner_lambda.function_name
}

output "agent_runner_lambda_role_arn" {
  description = "ARN of the Agent Runner Lambda execution role"
  value       = module.agent_runner_lambda.role_arn
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster for agent workers"
  value       = module.agent_worker_ecs.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster for agent workers"
  value       = module.agent_worker_ecs.cluster_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition for agent workers"
  value       = module.agent_worker_ecs.task_definition_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the IAM task role for agent container workers"
  value       = module.agent_worker_ecs.task_role_arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs where agent workers run"
  value       = module.vpc.private_subnet_ids
}

output "agent_compute_security_group_id" {
  description = "ID of the security group for agent workers"
  value       = module.vpc.agent_compute_security_group_id
}

output "step_functions_state_machine_arn" {
  description = "ARN of the Step Functions agent orchestrator state machine"
  value       = module.step_functions.state_machine_arn
}

output "step_functions_state_machine_name" {
  description = "Name of the Step Functions agent orchestrator state machine"
  value       = module.step_functions.state_machine_name
}

output "api_gateway_endpoint" {
  description = "Base URL of the API Gateway for client requests"
  value       = module.api_gateway.api_endpoint
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}

output "human_approvals_topic_arn" {
  description = "ARN of the SNS topic for human approval alerts"
  value       = module.notifications.human_approvals_topic_arn
}

output "budget_alerts_topic_arn" {
  description = "ARN of the SNS topic for tenant budget alerts"
  value       = module.notifications.budget_alerts_topic_arn
}

output "audit_event_bus_name" {
  description = "Name of the EventBridge audit event bus"
  value       = module.notifications.audit_event_bus_name
}






