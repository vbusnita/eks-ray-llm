output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region us-east-1 --profile terraform-local"
}

# Additional useful output
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}