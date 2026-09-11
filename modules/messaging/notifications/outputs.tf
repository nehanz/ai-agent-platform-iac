output "human_approvals_topic_arn" {
  description = "ARN of the SNS topic for human approval alerts"
  value       = aws_sns_topic.human_approvals.arn
}

output "budget_alerts_topic_arn" {
  description = "ARN of the SNS topic for tenant budget threshold alerts"
  value       = aws_sns_topic.budget_alerts.arn
}

output "audit_event_bus_arn" {
  description = "ARN of the EventBridge audit event bus"
  value       = aws_cloudwatch_event_bus.audit_bus.arn
}

output "audit_event_bus_name" {
  description = "Name of the EventBridge audit event bus"
  value       = aws_cloudwatch_event_bus.audit_bus.name
}
