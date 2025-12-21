#!/bin/bash
set -e  # Exit on any error

echo "🧹 Cleaning Terraform cache and lock..."
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

echo "🔄 Initializing with upgrade..."
terraform init -upgrade

echo "📋 Running plan..."
terraform plan

echo "✅ Done! Review the plan above."
