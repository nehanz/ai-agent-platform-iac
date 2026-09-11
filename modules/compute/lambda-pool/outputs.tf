output "function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = aws_lambda_function.function.arn
}

output "function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "role_arn" {
  description = "ARN of the IAM execution role assumed by the Lambda function"
  value       = aws_iam_role.lambda_exec.arn
}

output "role_name" {
  description = "Name of the IAM execution role assumed by the Lambda function"
  value       = aws_iam_role.lambda_exec.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
