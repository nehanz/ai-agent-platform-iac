locals {
  secret_path = var.tenant_id != null ? "/${var.project_name}/${var.environment}/tenants/${var.tenant_id}/${var.secret_name}" : "/${var.project_name}/${var.environment}/${var.secret_name}"
}

resource "aws_secretsmanager_secret" "this" {
  name                    = local.secret_path
  description             = var.description != null ? var.description : "Secret for ${var.project_name} (${var.secret_name})"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name        = local.secret_path
      Environment = var.environment
      TenantId    = var.tenant_id != null ? var.tenant_id : "platform"
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = var.secret_string != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_string
}
