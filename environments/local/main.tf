# 1. Platform Control-Plane KMS Key
module "platform_kms" {
  source = "../../modules/security/kms"

  key_scope    = "platform"
  environment  = var.environment
  project_name = var.project_name
  description  = "KMS key for AI Agent Platform control-plane and shared telemetry"
}

# 2. Reference Tenant Key
module "tenant_ref_kms" {
  source = "../../modules/security/kms"

  key_scope    = "tenant-ref"
  environment  = var.environment
  project_name = var.project_name
  description  = "Reference tenant KMS key for local validation of tenant data isolation"
}

# 3. Reference Tenant Tool Credential (Encrypted with Tenant KMS Key)
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

# 4. Immutable Audit Log Bucket (Encrypted with Platform KMS Key)
# - All tenants write to this shared bucket using path-prefix isolation: tenants/{tenant_id}/
# - The platform KMS key encrypts at the bucket level (SSE-KMS)
# - Object Lock (COMPLIANCE mode) ensures tamper-proof audit trails
module "audit_bucket" {
  source = "../../modules/storage/s3-audit"

  bucket_prefix              = var.project_name
  environment                = var.environment
  project_name               = var.project_name
  kms_key_arn                = module.platform_kms.key_arn
  object_lock_retention_days = 1   # Minimal for local testing; set 365+ for prod compliance
  glacier_transition_days    = 30  # Transition to Glacier after 30 days
}
