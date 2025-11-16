# ============================================================================
# MODULES/EKS/security_groups.tf
# ============================================================================

# ============================================================================
# SECURITY GROUP FOR EKS CLUSTER
# ============================================================================

resource "aws_security_group" "cluster" {
  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic from node groups"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
    }
  )
}

# ============================================================================
# SECURITY GROUP FOR NODE GROUPS
# ============================================================================

resource "aws_security_group" "node_group" {
  name_prefix = "${var.project_name}-${var.environment}-eks-node-group-"
  description = "Security group for EKS node groups"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic from cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow SSH access from specified CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cluster_endpoint_public_access_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks-node-group-sg"
    }
  )
}
