# security.tf: Hardens security groups for EKS

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443 # HTTPS for API server
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.api_ingress_ip}/32"] # Dynamic + /32 mask
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.cluster_name}-cluster-sg"
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true # Allow node-to-node
  }

  # Ray-specific ports (e.g., dashboard 8265, serve 8000)
  ingress {
    from_port   = 8000
    to_port     = 8265
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"] # VPC-internal only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "${var.cluster_name}-node-sg"
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}
