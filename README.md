# Ray LLM Demo EKS Cluster (Terraform + KubeRay)

Fully reproducible EKS + Ray on Kubernetes platform for vLLM LLM inference experiments.

**VICTORY ACHIEVED — December 21, 2025** 🎉🔥

RayCluster is **LIVE**:
- Head + worker pods Running
- Ray dashboard at `localhost:8265`
- Ready for Serve deployments and inference

## Repository Structure
```bash
eks-ray-llm/
├── README.md                    # This file – victory log + guide
├── collect-eks-data.py          # Original eksctl data dumper
├── eks-data-dump.json           # Reference from working eksctl cluster
├── infra/                       # Terraform (EKS + VPC)
│   ├── main.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── terraform.tfvars
│   └── ...
├── manifests/                   # Kubernetes manifests
│   ├── ray-cluster-cpu.yaml     # Working RayCluster (head + worker)
│   └── vllm-service.yaml        # Coming soon
├── serve_demo.py                # Ray Serve / vLLM demo

```

## The Journey (Never Forget)

Reversed-engineered a working `eksctl` cluster into pure Terraform:
- Public subnets + MapPublicIpOnLaunch
- AL2023 AMI + public node placement
- Cluster primary SG attached to nodes
- VPC CNI with `before_compute=true`
- Control plane logging + Container Insights
- Cost allocation tagging

Then deployed KubeRay → RayCluster → dashboard live.

## Usage

```bash
# Deploy infra
cd infra
terraform apply

# Connect
aws eks update-kubeconfig --name ray-llm-demo --region us-east-1 --profile terraform-local

# Install KubeRay operator
helm install kuberay-operator kuberay/kuberay-operator --namespace kuberay --create-namespace --version 1.2.0

# Deploy RayCluster
kubectl apply -f ../manifests/ray-cluster-cpu.yaml

# Dashboard
kubectl port-forward svc/ray-cluster-cpu-head-svc 8265:8265
open http://localhost:8265
```
