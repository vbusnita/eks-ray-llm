#!/bin/bash
set -e

# Safe destroy script for EKS infrastructure
# Performs proper cleanup order to prevent lingering resources

# Configuration - update these variables as needed
CLUSTER_NAME="${CLUSTER_NAME:-eks-ray-llm}"
REGION="${REGION:-us-east-1}"
PROFILE="${PROFILE:-terraform-local}"

echo "Starting safe destroy process for cluster: $CLUSTER_NAME"

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION" --profile "$PROFILE"

# Scale node groups to 0 to stop EC2 charges
echo "Scaling node groups to 0..."
aws eks update-nodegroup-config \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name cpu-xlarge \
  --scaling-config minSize=0,maxSize=0,desiredSize=0 \
  --region "$REGION" \
  --profile "$PROFILE" || echo "Warning: Failed to scale nodegroup (may already be scaled)"

# Wait for scaling to complete
echo "Waiting for nodes to scale down..."
sleep 60

# Delete Kubernetes resources (customize this section for your manifests)
echo "Deleting Kubernetes resources..."
# Add your specific Kubernetes manifests here
# kubectl delete -f ../k8s/ || true  # Uncomment and update path
kubectl delete pvc --all --all-namespaces || true
kubectl delete pv --all || true
kubectl delete ingress --all --all-namespaces || true
kubectl delete service --all --all-namespaces || true

# Remove EKS add-ons
echo "Removing EKS add-ons..."
aws eks delete-addon --cluster-name "$CLUSTER_NAME" --addon-name aws-ebs-csi-driver --region "$REGION" --profile "$PROFILE" || echo "Warning: Add-on may already be removed"
aws eks delete-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni --region "$REGION" --profile "$PROFILE" || echo "Warning: Add-on may already be removed"
aws eks delete-addon --cluster-name "$CLUSTER_NAME" --addon-name kube-proxy --region "$REGION" --profile "$PROFILE" || echo "Warning: Add-on may already be removed"
aws eks delete-addon --cluster-name "$CLUSTER_NAME" --addon-name coredns --region "$REGION" --profile "$PROFILE" || echo "Warning: Add-on may already be removed"

# Wait for add-on removal to complete
echo "Waiting for add-ons to be removed..."
sleep 120

# Refresh state to ensure accuracy
echo "Refreshing Terraform state..."
terraform refresh

# Run terraform destroy
echo "Running terraform destroy..."
terraform destroy -auto-approve

echo "Destroy complete! Check AWS console for any remaining resources."