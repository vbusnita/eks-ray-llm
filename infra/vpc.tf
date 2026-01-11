# vpc.tf: Manages VPC and subnets using the official module

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc-${random_string.suffix.result}"
  cidr = "192.168.0.0/16"

  azs             = ["us-east-1b", "us-east-1f"]
  private_subnets = ["192.168.64.0/19", "192.168.96.0/19"]
  public_subnets  = ["192.168.0.0/19", "192.168.32.0/19"]

  enable_nat_gateway     = false

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Environment                                 = "learning"
    Project                                     = "ray-llm"
    Owner                                       = "Victor Alexandru Busnita"
    Purpose                                     = "llm-experiments"
    DeploymentID                                = local.deployment_id
  }
}

# Outputs for cross-file refs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

# NAT Gateway resources with lifecycle for safe updates
resource "aws_eip" "nat" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name         = "${var.cluster_name}-nat-eip"
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.vpc.public_subnets[0] # Use first public subnet

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name         = "${var.cluster_name}-nat-gw"
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}

# Route for private subnets to NAT gateway
resource "aws_route" "private_nat_gateway" {
  route_table_id         = module.vpc.private_route_table_ids[0] # First private RT
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id

  lifecycle {
    create_before_destroy = true
  }
}