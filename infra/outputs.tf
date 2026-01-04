output "update_kubeconfig" {
  description = "Command to update kubeconfig for local kubectl access"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region us-east-1 --profile terraform-local"
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = module.eks.cluster_endpoint
}

# Additional info
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}
