locals {
  # FIFO queue names MUST end with ".fifo" — this is an AWS requirement.
  queue_full_name = "${var.project_name}-${var.environment}-${var.queue_name}.fifo"
  dlq_full_name   = "${var.project_name}-${var.environment}-${var.queue_name}-dlq.fifo"
}

# ─── Dead Letter Queue ────────────────────────────────────────────────────────
# The DLQ is created FIRST because the main queue's redrive policy references its ARN.
# When a message fails max_receive_count times (e.g. agent crashes repeatedly),
# SQS automatically moves it here instead of silently losing it.
# This gives you a safe place to inspect, alert on, or replay failed agent tasks.
resource "aws_sqs_queue" "dlq" {
  name                        = local.dlq_full_name
  fifo_queue                  = true
  content_based_deduplication = var.content_based_deduplication
  message_retention_seconds   = var.message_retention_seconds

  # KMS encryption for messages at rest in the DLQ.
  # kms_data_key_reuse_period_seconds: SQS caches the KMS data key for 5 minutes,
  # reducing KMS API calls and cost in high-throughput environments.
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? 300 : null

  tags = merge(
    var.tags,
    {
      Name        = local.dlq_full_name
      Environment = var.environment
      QueueType   = "dead-letter-queue"
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Main Agent Task Queue ────────────────────────────────────────────────────
# FIFO guarantees strict ordering per MessageGroupId (which will be set to tenant_id
# at runtime). This ensures agent tasks for Tenant A are processed in submission order,
# and one tenant's backlog cannot block another tenant's tasks.
resource "aws_sqs_queue" "main" {
  name                        = local.queue_full_name
  fifo_queue                  = true
  content_based_deduplication = var.content_based_deduplication
  message_retention_seconds   = var.message_retention_seconds

  # Visibility timeout: duration a message is hidden from other consumers
  # after being received by one consumer. Must be >= your agent's max runtime.
  # If the agent finishes successfully, it deletes the message.
  # If it crashes or times out, the message reappears after this duration.
  visibility_timeout_seconds = var.visibility_timeout_seconds

  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? 300 : null

  # Redrive policy: after max_receive_count failed attempts, move message to DLQ.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(
    var.tags,
    {
      Name        = local.queue_full_name
      Environment = var.environment
      QueueType   = "main-agent-task-queue"
      ManagedBy   = "Terraform"
    }
  )
}
