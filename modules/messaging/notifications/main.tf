locals {
  topic_prefix = "${var.project_name}-${var.environment}"
}

# ─── Human Approvals SNS Topic ────────────────────────────────────────────────
# Dispatches notifications (Email, Slack, Webhook) when an agent requires human
# confirmation before executing high-consequence operations (e.g. refunds > $1000).
resource "aws_sns_topic" "human_approvals" {
  name              = "${local.topic_prefix}-human-approvals"
  kms_master_key_id = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name        = "${local.topic_prefix}-human-approvals"
      Environment = var.environment
      Purpose     = "human-in-the-loop-approval"
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Tenant Budget Alerts SNS Topic ───────────────────────────────────────────
# Alerts platform operators when a tenant reaches 80% or 100% of their daily token budget.
resource "aws_sns_topic" "budget_alerts" {
  name              = "${local.topic_prefix}-budget-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = merge(
    var.tags,
    {
      Name        = "${local.topic_prefix}-budget-alerts"
      Environment = var.environment
      Purpose     = "tenant-cost-control"
      ManagedBy   = "Terraform"
    }
  )
}

# ─── EventBridge Audit Event Bus ──────────────────────────────────────────────
# Central asynchronous event stream for decoupled audit, monitoring, and compliance events.
resource "aws_cloudwatch_event_bus" "audit_bus" {
  name = "${local.topic_prefix}-audit-bus"

  tags = merge(
    var.tags,
    {
      Name        = "${local.topic_prefix}-audit-bus"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── EventBridge Audit Rule ───────────────────────────────────────────────────
# Filters and routes all platform audit events to target subscribers.
resource "aws_cloudwatch_event_rule" "audit_events" {
  name           = "${local.topic_prefix}-audit-rule"
  description    = "Captures all agent decision and tool execution events"
  event_bus_name = aws_cloudwatch_event_bus.audit_bus.name

  event_pattern = jsonencode({
    source = [
      "ai.agent.platform"
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${local.topic_prefix}-audit-rule"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
