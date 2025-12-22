variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "ray-llm-demo"
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
