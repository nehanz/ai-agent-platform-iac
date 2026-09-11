output "cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "task_definition_arn" {
  description = "ARN of the ECS Task Definition for agent workers"
  value       = aws_ecs_task_definition.task.arn
}

output "task_family" {
  description = "Family name of the Task Definition"
  value       = aws_ecs_task_definition.task.family
}

output "execution_role_arn" {
  description = "ARN of the IAM execution role used by the ECS container agent"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "ARN of the IAM task role used by the running agent container"
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS task logs"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS task logs"
  value       = aws_cloudwatch_log_group.ecs_logs.arn
}
