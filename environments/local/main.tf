# Control-plane encryption key shared across platform-owned resources:
module "platform_kms" {
  source = "../../modules/security/kms"

  key_scope    = "platform"
  environment  = var.environment
  project_name = var.project_name
  description  = "KMS key for AI Agent Platform control-plane and shared telemetry"
}

# Simulates a per-tenant Customer Managed Key used in local testing.
module "tenant_ref_kms" {
  source = "../../modules/security/kms"

  key_scope    = "tenant-ref"
  environment  = var.environment
  project_name = var.project_name
  description  = "Reference tenant KMS key for local validation of tenant data isolation"
}

# Simulates a tenant's external tool credential (e.g. GitHub API token).
module "tenant_ref_tool_secret" {
  source = "../../modules/security/secrets-manager"

  secret_name   = "tools/github-token"
  kms_key_arn   = module.tenant_ref_kms.key_arn
  tenant_id     = "tenant-ref"
  environment   = var.environment
  project_name  = var.project_name
  description   = "Sample tool credential encrypted with tenant KMS key"
  secret_string = "{\"api_key\":\"ghp_mock_token_for_tenant_ref\"}"
}

# Tamper-proof audit log bucket for all AI agent activity (prompts, tool calls,
module "audit_bucket" {
  source = "../../modules/storage/s3-audit"

  bucket_prefix              = var.project_name
  environment                = var.environment
  project_name               = var.project_name
  kms_key_arn                = module.platform_kms.key_arn
  object_lock_retention_days = 1
  glacier_transition_days    = 30
}

# Master record of every registered tenant: tenant_id, home region, KMS key ARN, status.
module "tenant_registry_table" {
  source = "../../modules/data/dynamodb"

  table_name   = "tenant-registry"
  environment  = var.environment
  project_name = var.project_name
  hash_key     = "tenant_id"
  kms_key_arn  = module.platform_kms.key_arn

  attributes = [
    { name = "tenant_id", type = "S" }
  ]
}

# Active agent conversation state per tenant. TTL auto-purges sessions after
module "agent_sessions_table" {
  source = "../../modules/data/dynamodb"

  table_name    = "agent-sessions"
  environment   = var.environment
  project_name  = var.project_name
  hash_key      = "tenant_id"
  range_key     = "session_id"
  kms_key_arn   = module.tenant_ref_kms.key_arn
  ttl_attribute = "expires_at"

  attributes = [
    { name = "tenant_id",  type = "S" },
    { name = "session_id", type = "S" }
  ]
}

# Token consumption and cost tracking per tenant per billing period.
module "tenant_budgets_table" {
  source = "../../modules/data/dynamodb"

  table_name   = "tenant-budgets"
  environment  = var.environment
  project_name = var.project_name
  hash_key     = "tenant_id"
  range_key    = "billing_period"
  kms_key_arn  = module.tenant_ref_kms.key_arn

  attributes = [
    { name = "tenant_id",      type = "S" },
    { name = "billing_period", type = "S" }
  ]
}

# FIFO queue for dispatching agent tasks to ECS Fargate workers.
module "agent_task_queue" {
  source = "../../modules/messaging/sqs-fifo"

  queue_name   = "agent-tasks"
  environment  = var.environment
  project_name = var.project_name
  kms_key_arn  = module.platform_kms.key_arn

  visibility_timeout_seconds = 300   # Must be >= agent max processing time
  message_retention_seconds  = 86400 # Retain unprocessed messages for 24h
  max_receive_count          = 3
}

# Serverless worker compute instance for running agent tasks, session management,
# and tool credential retrieval with least-privilege IAM permissions.
module "agent_runner_lambda" {
  source = "../../modules/compute/lambda-pool"

  function_name = "agent-runner"
  environment   = var.environment
  project_name  = var.project_name
  description   = "Serverless worker for executing agent tasks and tool integrations"

  memory_size = 512
  timeout     = 60

  environment_variables = {
    ENVIRONMENT           = var.environment
    PROJECT_NAME          = var.project_name
    TENANT_REGISTRY_TABLE = module.tenant_registry_table.table_name
    AGENT_SESSIONS_TABLE  = module.agent_sessions_table.table_name
    TENANT_BUDGETS_TABLE  = module.tenant_budgets_table.table_name
    AUDIT_BUCKET_NAME     = module.audit_bucket.bucket_name
    TASK_QUEUE_URL        = module.agent_task_queue.queue_url
  }

  dynamodb_table_arns = [
    module.tenant_registry_table.table_arn,
    module.agent_sessions_table.table_arn,
    module.tenant_budgets_table.table_arn
  ]

  sqs_queue_arns = [
    module.agent_task_queue.queue_arn,
    module.agent_task_queue.dlq_arn
  ]

  s3_bucket_arns = [
    module.audit_bucket.bucket_arn
  ]

  secrets_manager_arns = [
    module.tenant_ref_tool_secret.secret_arn
  ]

  kms_key_arns = [
    module.platform_kms.key_arn,
    module.tenant_ref_kms.key_arn
  ]
}

