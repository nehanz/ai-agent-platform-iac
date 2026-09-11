locals {
  # OpenSearch Serverless collection names must be 3-32 lowercase alphanumeric or hyphens
  collection_full_name = lower("${var.project_name}-${var.environment}-${var.collection_name}")
}

# ─── Encryption Security Policy ───────────────────────────────────────────────
# Enforces KMS encryption for all vector data stored in the collection.
# Must be created before the collection itself.
resource "aws_opensearchserverless_security_policy" "encryption" {
  name        = "${local.collection_full_name}-enc"
  type        = "encryption"
  description = "KMS encryption policy for ${local.collection_full_name}"

  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection"
        Resource = [
          "collection/${local.collection_full_name}"
        ]
      }
    ]
    AWSOwnedKey = var.kms_key_arn == null ? true : false
    KmsARN      = var.kms_key_arn
  })
}

# ─── Network Security Policy ──────────────────────────────────────────────────
# Controls network routing to the vector search collection endpoint and dashboard.
resource "aws_opensearchserverless_security_policy" "network" {
  name        = "${local.collection_full_name}-net"
  type        = "network"
  description = "Network access policy for ${local.collection_full_name}"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${local.collection_full_name}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${local.collection_full_name}"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# ─── Data Access Policy ───────────────────────────────────────────────────────
# Grants IAM execution roles (ECS agent tasks, Lambda workers) access to create,
# query, and manage vector indices within the collection.
resource "aws_opensearchserverless_access_policy" "data" {
  name        = "${local.collection_full_name}-data"
  type        = "data"
  description = "Data access policy for agent workers and compute principals"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            "index/${local.collection_full_name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        },
        {
          ResourceType = "collection"
          Resource = [
            "collection/${local.collection_full_name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        }
      ]
      Principal = length(var.principal_arns) > 0 ? var.principal_arns : ["*"]
    }
  ])
}

# ─── Vector Search Collection ─────────────────────────────────────────────────
# Serverless vector database collection configured specifically for embedding storage,
# k-NN semantic search, and agent memory retrieval.
resource "aws_opensearchserverless_collection" "this" {
  name        = local.collection_full_name
  description = var.description
  type        = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]

  tags = merge(
    var.tags,
    {
      Name        = local.collection_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
