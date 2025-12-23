module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.cluster_name
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
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  endpoint_public_access       = true
  endpoint_private_access      = false
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_cluster_creator_admin_permissions = true

  enabled_log_types                      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 90
  cloudwatch_log_group_kms_key_id        = null

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    worker = {
      name           = "worker"
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      instance_types = ["m5.large"]

      ami_type   = "AL2023_x86_64_STANDARD"
      subnet_ids = module.vpc.public_subnets

      labels = {
        role                             = "general"
        "alpha.eksctl.io/cluster-name"   = var.cluster_name
        "alpha.eksctl.io/nodegroup-name" = "worker"
      }
      tags = {
        Environment = "learning"
        Project     = "ray-llm"
        Owner       = "Victor Alexandru Busnita"
        Purpose     = "llm-experiments"
      }

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      additional_security_group_ids = [module.eks.cluster_primary_security_group_id]
    }
  }

  tags = {
    Environment = "learning"
    Project     = "ray-llm"
    Owner       = "Victor Alexandru Busnita"
    Purpose     = "llm-experiments"
  }
}

output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region us-east-1 --profile terraform-local"
}
