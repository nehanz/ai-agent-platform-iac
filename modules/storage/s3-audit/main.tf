resource "random_id" "bucket_suffix" {
  # Generates a globally unique suffix for the S3 bucket name.
  # S3 bucket names are globally unique across all AWS accounts worldwide,
  # so a random suffix prevents naming collisions between environments.
  byte_length = 4
}

locals {
  bucket_name = "${var.bucket_prefix}-${var.environment}-audit-${random_id.bucket_suffix.hex}"
}

# ─── 1. The S3 Bucket ─────────────────────────────────────────────────────────
# Object Lock must be enabled at CREATION TIME — it cannot be added after.
# This is the WORM (Write Once, Read Many) foundation of the audit trail.
resource "aws_s3_bucket" "audit" {
  bucket              = local.bucket_name
  object_lock_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = local.bucket_name
      Environment = var.environment
      Purpose     = "immutable-audit-log"
      ManagedBy   = "Terraform"
    }
  )
}

# ─── 2. Versioning ────────────────────────────────────────────────────────────
# Versioning is a MANDATORY prerequisite for Object Lock to function.
# Every PUT to this bucket creates a new version with its own immutable lock.
resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─── 3. Object Lock Configuration (COMPLIANCE mode) ──────────────────────────
# COMPLIANCE mode means NO ONE — not even the AWS root account — can delete or
# overwrite a locked object until its retention period expires.
# GOVERNANCE mode would allow admins with special IAM permissions to override.
resource "aws_s3_bucket_object_lock_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = var.object_lock_retention_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.audit]
}

# ─── 4. Server-Side Encryption with KMS (SSE-KMS) ────────────────────────────
# Every object stored in this bucket is automatically encrypted at rest
# using our platform KMS Customer Managed Key. The bucket_key_enabled flag
# reduces KMS API calls (and cost) by using a bucket-level data key.
resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

# ─── 5. Block ALL Public Access ───────────────────────────────────────────────
# Enforces all four public access blocks regardless of bucket ACLs or policies.
# An audit log bucket must NEVER be publicly accessible under any circumstances.
resource "aws_s3_bucket_public_access_block" "audit" {
  bucket = aws_s3_bucket.audit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── 6. Lifecycle Rules ────────────────────────────────────────────────────────
# Cost-optimization: older audit logs that have passed their active review window
# are transitioned to Glacier (90% cheaper than Standard storage).
# This does NOT delete them — Object Lock still prevents deletion.
resource "aws_s3_bucket_lifecycle_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    id     = "archive-old-audit-logs-to-glacier"
    status = "Enabled"

    # Empty filter means this rule applies to ALL objects in the bucket.
    # AWS provider v5 requires an explicit filter block even when targeting all objects.
    filter {}

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }
  }

  depends_on = [aws_s3_bucket_versioning.audit]
}
