data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "default_key_policy" {
  statement {
    sid       = "EnableIAMUserPermissions"
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "this" {
  description             = var.description != null ? var.description : "KMS CMK for ${var.project_name} ${var.environment} (${var.key_scope})"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = var.custom_key_policy != null ? var.custom_key_policy : data.aws_iam_policy_document.default_key_policy.json

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-${var.key_scope}-key"
      Environment = var.environment
      KeyScope    = var.key_scope
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project_name}-${var.environment}-${var.key_scope}"
  target_key_id = aws_kms_key.this.key_id
}
