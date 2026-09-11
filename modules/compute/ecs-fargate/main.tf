locals {
  cluster_full_name = "${var.project_name}-${var.environment}-${var.cluster_name}"
  service_full_name = "${var.project_name}-${var.environment}-${var.service_name}"
  task_family       = "${var.project_name}-${var.environment}-${var.service_name}"
}

# Dedicated cluster for agent worker tasks. Manages container orchestration and telemetry.
resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_full_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    {
      Name        = local.cluster_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Enables serverless execution so no EC2 instances need to be provisioned or patched.
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

# Centralized logging for container stdout/stderr with retention lifecycle.
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${local.service_full_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.tags,
    {
      Name        = "/ecs/${local.service_full_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    sid     = "ECSTasksAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Used by the ECS agent to pull container images, write logs to CloudWatch, and fetch secrets.
resource "aws_iam_role" "execution" {
  name               = "${local.service_full_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.service_full_name}-execution-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

data "aws_iam_policy_document" "execution_policy_doc" {
  statement {
    sid    = "ECRAndLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "execution_policy" {
  name        = "${local.service_full_name}-execution-policy"
  description = "Execution role permissions for ECS agent"
  policy      = data.aws_iam_policy_document.execution_policy_doc.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.service_full_name}-execution-policy"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "execution_attach" {
  role       = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.execution_policy.arn
}

# Used by the running agent container to access DynamoDB, SQS, S3, Secrets Manager, and KMS.
resource "aws_iam_role" "task" {
  name               = "${local.service_full_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.service_full_name}-task-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

data "aws_iam_policy_document" "task_policy_doc" {
  # DynamoDB permissions
  dynamic "statement" {
    for_each = length(var.dynamodb_table_arns) > 0 ? [1] : []
    content {
      sid    = "DynamoDBTableAccess"
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem"
      ]
      resources = flatten([
        for arn in var.dynamodb_table_arns : [
          arn,
          "${arn}/index/*"
        ]
      ])
    }
  }

  # SQS permissions
  dynamic "statement" {
    for_each = length(var.sqs_queue_arns) > 0 ? [1] : []
    content {
      sid    = "SQSQueueAccess"
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:SendMessage",
        "sqs:ChangeMessageVisibility"
      ]
      resources = var.sqs_queue_arns
    }
  }

  # S3 permissions
  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []
    content {
      sid    = "S3BucketAccess"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      resources = flatten([
        for arn in var.s3_bucket_arns : [
          arn,
          "${arn}/*"
        ]
      ])
    }
  }

  # Secrets Manager permissions
  dynamic "statement" {
    for_each = length(var.secrets_manager_arns) > 0 ? [1] : []
    content {
      sid    = "SecretsManagerAccess"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = var.secrets_manager_arns
    }
  }

  # KMS decryption permissions
  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [1] : []
    content {
      sid    = "KMSDecryptionAccess"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*"
      ]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_policy" "task_policy" {
  name        = "${local.service_full_name}-task-policy"
  description = "Application permissions for agent worker container"
  policy      = data.aws_iam_policy_document.task_policy_doc.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.service_full_name}-task-policy"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "task_attach" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task_policy.arn
}

# Defines the container specification, environment variables, resource limits, and logging.
resource "aws_ecs_task_definition" "task" {
  family                   = local.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "agent-worker"
      image     = var.container_image
      essential = true

      environment = [
        for k, v in var.environment_variables : {
          name  = k
          value = v
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = local.task_family
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Deploys a managed service if VPC subnets are provided.
resource "aws_ecs_service" "service" {
  count           = length(var.subnet_ids) > 0 ? 1 : 0
  name            = local.service_full_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  tags = merge(
    var.tags,
    {
      Name        = local.service_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
