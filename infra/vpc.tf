# vpc.tf: Manages VPC and subnets using the official module

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["us-east-1b", "us-east-1f"]
  private_subnets = ["192.168.64.0/19", "192.168.96.0/19"]
  public_subnets  = ["192.168.0.0/19", "192.168.32.0/19"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

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