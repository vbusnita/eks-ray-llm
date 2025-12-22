# Ray LLM Demo EKS Cluster (Terraform)

Fully reproducible Amazon EKS cluster for Ray on Kubernetes + vLLM inference experiments.

Built December 21, 2025 after an epic multi-day grind reverse-engineering `eksctl` behavior into pure Terraform.

## Status: VICTORY 🎉

Cluster is **Active**, nodes **Ready**, kubectl working:
```bash
NAME                                   STATUS   ROLES    AGE   VERSION
ip-192-168-1-253.ec2.internal          Ready       11m   v1.30.14-eks-ecaa3a6
```

Core pods healthy:
- aws-node (VPC CNI)
- kube-proxy
- CoreDNS

## Project Structure
eks-ray-llm/
├── README.md                    # This file – project overview + battle story
├── infra/                       # Terraform configuration
│   ├── main.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── terraform.tfvars         # Local values (gitignore if sensitive)
│   ├── terraform.tfstate        # Local state (never commit!)
│   ├── tf-clean-init-plan.sh    # Helper script
│   └── tf-destroy-no-prompt.sh  # Helper script
├── serve_demo.py                # Example Ray Serve / vLLM demo script


## Key Features & Fixes (The War Story)

The Terraform config in `infra/` exactly replicates (and improves on) a working `eksctl` cluster:

- **VPC**: 192.168.0.0/16 CIDR, /19 subnets across us-east-1b & us-east-1f
- **Public subnets** with `map_public_ip_on_launch = true`
- **Nodes in public subnets** using AL2023 AMI (matches eksctl default)
- **Security**: Cluster primary SG attached to nodes
- **VPC CNI**: Addon with `before_compute = true` (fixes initialization race)
- **Monitoring**: Control plane logging + Container Insights enabled
- **Tagging**: Consistent tags (Project=ray-llm, Environment=learning, NodeGroup) for cost allocation
- **Reproducibility**: `.terraform.lock.hcl` committed in `infra/` for exact provider versions

## Major gotchas defeated:
- Public IP assignment
- Control plane ↔ node security group communication
- VPC CNI bootstrap ordering
- Module/addon version changes

## Usage

```bash
# 1. Enter infra directory
cd infra

# 2. Initialize
terraform init

# 3. Plan
terraform plan

# 4. Deploy
terraform apply

# 5. Connect to cluster
aws eks update-kubeconfig --name ray-llm-demo --region us-east-1 --profile terraform-local

# 6. Verify
kubectl get nodes -o wide
```
kubectl get pods --all-namespaces
