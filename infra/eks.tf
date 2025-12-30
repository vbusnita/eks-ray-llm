# eks.tf: Manages EKS cluster and node groups

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # Private for security; concat with public if needed for ELBs

  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks_cluster_role.arn # Custom cluster role

  enable_irsa = true # Enables OIDC/IRSA for add-ons like CSI

  endpoint_public_access       = true
  endpoint_private_access      = false
  endpoint_public_access_cidrs = ["0.0.0.0/0"] # Restrict to your IP in prod

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
    aws-ebs-csi-driver = {
      most_recent = true # Module manages CSI without custom role to avoid cycle
    }
  }

  eks_managed_node_groups = {
    cpu_xlarge = {
      name         = "cpu-xlarge"
      min_size     = 0
      max_size     = 3
      desired_size = 1

      instance_types = ["m5.xlarge"]
      ami_type       = "AL2023_x86_64_STANDARD"

      disk_size = 100 # Fixes DiskPressure

      create_iam_role = false # Use custom node role
      iam_role_arn    = aws_iam_role.eks_node_role.arn

      subnet_ids = module.vpc.private_subnets

      vpc_security_group_ids = [aws_security_group.eks_node_sg.id] # Attach custom node SG

      labels = {
        role = "cpu-xlarge"
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
      additional_security_group_ids = [module.eks.cluster_security_group_id]
    }
  }

  tags = {
    Environment = "learning"
    Project     = "ray-llm"
    Owner       = "Victor Alexandru Busnita"
    Purpose     = "llm-experiments"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}