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

variable "node_group_desired_size" {
  description = "Desired size for CPU node group (scale to 0 for drain)"
  type        = number
  default     = 1
}

variable "deployment_id" {
  description = "Unique identifier for this deployment (used in tags for cleanup)"
  type        = string
  default     = ""  # Will be set via random_uuid if empty
}

variable "endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access EKS API server publicly"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Override with your IP for security (e.g., ["YOUR_IP/32"])
}

variable "aws_auth_roles" {
  description = "Additional IAM roles to add to aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "Additional IAM users to add to aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      userarn  = "arn:aws:iam::823262829953:root"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}
