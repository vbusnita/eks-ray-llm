# iam.tf: Manages IAM roles and policies for EKS

# EKS Cluster Role: Allows EKS service to manage the control plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role" # Use variables for reusability

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}

# Attach necessary policies to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS Node Group Role: For worker nodes to interact with AWS services
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}

# Attach policies to node role (least privilege for EKS workers)
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

module "ebs_csi_driver_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.46" # Latest as of Jan 2026, fixes deprecated .name → .id

  role_name_prefix = "${var.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment  = "learning"
    Project      = "ray-llm"
    Owner        = "Victor Alexandru Busnita"
    Purpose      = "llm-experiments"
    DeploymentID = local.deployment_id
  }
}

output "ebs_csi_irsa_role_arn" {
  value       = module.ebs_csi_driver_irsa_role.iam_role_arn
  description = "ARN of IRSA role for EBS CSI driver"
}
