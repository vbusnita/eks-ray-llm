# Makefile for Terraform automation
# Run 'make <target>' to execute common Terraform commands

.PHONY: validate tflint plan plan-destroy apply destroy clean init refresh

# Initialize Terraform
init:
	terraform init

# Validate Terraform configuration
validate:
	terraform validate

# Run TFLint for linting
tflint:
	tflint --init
	tflint

# Plan Terraform changes
plan:
	terraform plan

# Plan destroy operation (safe preview)
plan-destroy:
	terraform plan -destroy

# Apply Terraform changes
apply:
	terraform apply

# Destroy infrastructure
destroy:
	terraform destroy

# Refresh Terraform state
refresh:
	terraform refresh

# Clean Terraform cache
clean:
	rm -rf .terraform .terraform.lock.hcl

# Full validation pipeline
check: validate tflint plan