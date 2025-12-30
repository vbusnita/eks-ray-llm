terraform {
  backend "s3" {
    bucket  = "eks-ray-llm-state-bucket"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "terraform-local"
  }
}