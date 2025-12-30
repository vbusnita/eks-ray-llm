#!/bin/bash
set -e  # Exit on any error

echo "🧹 Cleaning Terraform cache and lock..."
rm -rf .terraform/modules .terraform/providers .terraform/terraform.tfstate

echo "🔄 Initializing with upgrade..."
terraform init -upgrade

echo "📋 Running plan..."
terraform plan

echo "✅ Done! Review the plan above."
