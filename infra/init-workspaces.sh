#!/bin/bash
# Initialize Terraform with workspaces enabled
# Run this after cloning the repo to set up workspaces

set -e

echo "Initializing Terraform..."
terraform init

echo "Setting up default workspace..."
terraform workspace select default || terraform workspace new default

echo "Workspace initialization complete. Current workspace: $(terraform workspace show)"