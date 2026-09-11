output "state_machine_arn" {
  description = "ARN of the Step Functions State Machine"
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions State Machine"
  value       = aws_sfn_state_machine.this.name
}

output "state_machine_id" {
  description = "ID of the Step Functions State Machine"
  value       = aws_sfn_state_machine.this.id
}

output "role_arn" {
  description = "ARN of the IAM execution role assumed by Step Functions"
  value       = aws_iam_role.sfn_exec.arn
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for State Machine execution logs"
  value       = aws_cloudwatch_log_group.sfn_logs.arn
}
