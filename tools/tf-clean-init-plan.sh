#!/bin/bash
set -e
cd ../infra
echo "🧹 Full clean: state, modules, providers, lock..."
rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate*

echo "🔄 Re-initializing with upgrade..."
terraform init -upgrade

echo "📋 Running plan..."
terraform plan

echo "✅ Clean plan complete!"