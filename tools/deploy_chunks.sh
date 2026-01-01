#!/bin/bash
set -e  # Exit on error
cd ../infra/
echo "Chunk 1: VPC & Subnets"
terraform apply -target=module.vpc -auto-approve
echo "Chunk 2: IAM Roles & Policies"
terraform apply -target=aws_iam_role.eks_cluster_role -target=aws_iam_role_policy_attachment.eks_cluster_policy -target=aws_iam_role_policy_attachment.eks_vpc_resource_controller -target=aws_iam_role.eks_node_role -target=aws_iam_role_policy_attachment.eks_worker_node_policy -target=aws_iam_role_policy_attachment.eks_cni_policy -target=aws_iam_role_policy_attachment.ec2_container_registry_read_only -target=aws_iam_role_policy_attachment.ebs_csi_driver_policy -target=module.ebs_csi_driver_irsa_role -target=aws_iam_role_policy_attachment.ebs_csi_irsa_explicit -auto-approve
echo "Chunk 3: Security Groups"
terraform apply -target=aws_security_group.eks_cluster_sg -target=aws_security_group.eks_node_sg -auto-approve
echo "Chunk 4: EKS Cluster Core & Node Group"
terraform apply -target=module.eks -auto-approve
echo "Chunk 5: EBS CSI IRSA & Add-on"
terraform apply -target=aws_eks_addon.ebs_csi_driver -auto-approve  # Standalone, explicit depends_on in code
echo "Chunk 6: aws-auth Map"
terraform apply -target=null_resource.aws_auth_map -auto-approve
echo "Full cluster deployed via chunks! Verify with kubectl get nodes."