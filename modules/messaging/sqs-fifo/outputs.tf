output "queue_id" {
  description = "The URL of the main SQS FIFO queue (used by producers/consumers to send and receive messages)"
  value       = aws_sqs_queue.main.id
}

output "queue_url" {
  description = "The URL of the main SQS FIFO queue (alias for queue_id)"
  value       = aws_sqs_queue.main.id
}

output "queue_arn" {
  description = "The ARN of the main SQS FIFO queue (used in IAM policies for Lambda/ECS task roles)"
  value       = aws_sqs_queue.main.arn
}

output "queue_name" {
  description = "The full name of the main SQS FIFO queue"
  value       = aws_sqs_queue.main.name
}

output "dlq_id" {
  description = "The URL of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_url" {
  description = "The URL of the Dead Letter Queue (alias for dlq_id)"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "The ARN of the Dead Letter Queue (used for CloudWatch alarms on failed messages)"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "The full name of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.name
}

