#!/bin/bash
set -e  # Exit on error
cd ../infra/

# Create timestamped log directory
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="../tools/logs/$TIMESTAMP"
mkdir -p "$LOG_DIR"

# Main deployment log — only detailed DEBUG output goes here
DEBUG_LOG="$LOG_DIR/terraform-debug.log"

echo "Deployment started at $TIMESTAMP"
echo "Clean console output — full DEBUG logs in $LOG_DIR"
echo

echo "Chunk 1: VPC & Subnets"
echo "======================="
terraform apply -target=module.vpc -auto-approve 2>&1 | tee -a "$DEBUG_LOG"

echo
echo "Chunk 2: IAM Roles & Policies (Core Only, No IRSA)"
echo "==================================================="
terraform apply \
    -target=aws_iam_role.eks_cluster_role \
    -target=aws_iam_role_policy_attachment.eks_cluster_policy \
    -target=aws_iam_role_policy_attachment.eks_vpc_resource_controller \
    -target=aws_iam_role.eks_node_role \
    -target=aws_iam_role_policy_attachment.eks_worker_node_policy \
    -target=aws_iam_role_policy_attachment.eks_cni_policy \
    -target=aws_iam_role_policy_attachment.ec2_container_registry_read_only \
    -target=aws_iam_role_policy_attachment.ebs_csi_driver_policy \
    -auto-approve 2>&1 | tee -a "$DEBUG_LOG"

echo
echo "Chunk 3: Security Groups"
echo "========================="
terraform apply -target=aws_security_group.eks_cluster_sg \
    -target=aws_security_group.eks_node_sg -auto-approve 2>&1 | tee -a "$DEBUG_LOG"

echo
echo "Chunk 4: EKS Cluster Core & Node Group"
echo "======================================="
terraform apply -target=module.eks -auto-approve 2>&1 | tee -a "$DEBUG_LOG"

echo
echo "Chunk 5: EBS CSI IRSA & Add-on"
echo "==============================="
terraform apply -target=module.ebs_csi_driver_irsa_role \
    -target=aws_iam_role_policy_attachment.ebs_csi_irsa_explicit \
    -target=aws_eks_addon.ebs_csi_driver -auto-approve 2>&1 | tee -a "$DEBUG_LOG"

echo
echo "Chunk 6: aws-auth Map"
echo "======================"
terraform apply -target=null_resource.aws_auth_map -auto-approve 2>&1 | tee -a "$DEBUG_LOG"

echo
echo "=== DONE! ==="
echo "Full cluster deployed via chunks!"
echo "Normal output shown above"
echo "Full DEBUG logs in: $LOG_DIR/terraform-debug.log"
echo "Verify with: kubectl get nodes"