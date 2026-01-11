terraform {
  backend "s3" {
    bucket         = "eks-ray-llm-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    profile        = "terraform-local"
    dynamodb_table = "eks-ray-llm-terraform-locks"  # Create this table manually: primary key "LockID" (String)
  }
}