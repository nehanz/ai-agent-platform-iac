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
