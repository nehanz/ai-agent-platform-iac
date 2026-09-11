output "table_id" {
  description = "The DynamoDB table ID (same as name)"
  value       = aws_dynamodb_table.this.id
}

output "table_name" {
  description = "The full table name including environment prefix"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "The ARN of the DynamoDB table (used in IAM policies for Lambda/ECS task roles)"
  value       = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  description = "The ARN of the DynamoDB stream (if enabled). Used to attach Lambda triggers."
  value       = aws_dynamodb_table.this.stream_arn
}
