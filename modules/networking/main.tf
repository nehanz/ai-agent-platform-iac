locals {
  vpc_name = "${var.project_name}-${var.environment}-vpc"
}

# ─── Virtual Private Cloud (VPC) ──────────────────────────────────────────────
# Isolated network container for hosting agent execution compute and data stores.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name        = local.vpc_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Internet Gateway ─────────────────────────────────────────────────────────
# Enables outbound internet access for public subnets (e.g. NAT gateways / external tool APIs).
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-igw"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Public Subnets ───────────────────────────────────────────────────────────
# Subnets with direct route to Internet Gateway across multiple Availability Zones.
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-public-${var.availability_zones[count.index % length(var.availability_zones)]}"
      Environment = var.environment
      Type        = "public"
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Private Subnets ──────────────────────────────────────────────────────────
# Subnets for running agent workers (Lambda/ECS) and data services with no direct internet ingress.
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-private-${var.availability_zones[count.index % length(var.availability_zones)]}"
      Environment = var.environment
      Type        = "private"
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Public Route Table & Associations ────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-public-rt"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ─── Private Route Table & Associations ───────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-private-rt"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ─── Security Group for Agent Compute ─────────────────────────────────────────
# Applied to ECS Fargate agent workers and Lambda execution environments.
resource "aws_security_group" "agent_compute" {
  name        = "${var.project_name}-${var.environment}-agent-compute-sg"
  description = "Security group for AI agent compute workers"
  vpc_id      = aws_vpc.this.id

  # Allow all outbound traffic for API calls, tool invocations, and AWS services
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-agent-compute-sg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Security Group for VPC Endpoints ─────────────────────────────────────────
# Restricts access to VPC interface endpoints strictly to internal compute security groups.
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for private VPC interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTPS from agent compute workers"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.agent_compute.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── VPC Gateway Endpoints (S3 & DynamoDB) ────────────────────────────────────
# Free private routing for high-throughput S3 audit logging and DynamoDB session lookups
# without routing traffic over the public internet or NAT gateways.
resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_gateway_endpoints ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-s3-endpoint"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  count             = var.enable_gateway_endpoints ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]

  tags = merge(
    var.tags,
    {
      Name        = "${local.vpc_name}-dynamodb-endpoint"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
