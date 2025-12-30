variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-ray-llm"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "terraform-local"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "api_ingress_ip" {
  description = "Your public IP for EKS API server access (e.g., from curl ifconfig.me)"
  type        = string
  default     = "0.0.0.0/0" # Fallback open for testing; override locally
  sensitive   = true        # Hides value in terraform plan/apply output
}
