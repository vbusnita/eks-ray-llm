# Ray LLM Demo EKS Cluster (Terraform + KubeRay)

Fully reproducible EKS + Ray on Kubernetes platform for vLLM LLM inference experiments.

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
│   ├── eks.tf
│   ├── iam.tf
│   ├── security.tf
│   ├── backend.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── tf-clean-init-plan.sh
│   ├── tf-destroy-no-prompt.sh
│   └── .terraform.lock.hcl
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

<img width="2611" height="1082" alt="Screenshot 2025-12-21 at 20 29 26" src="https://github.com/user-attachments/assets/daa247d6-b94c-45c7-9fbe-cde318810a0e" />

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

## 🤖 AI-Augmented Workflow (Powered by xAI Grok Collections) 🚀

This repository is now **self-aware** — every file is automatically indexed into a persistent knowledge base using the **xAI Grok Collections API**.

### Key Features
- **Full codebase indexed**: All meaningful files (`infra/`, `manifests/`, `serve_demo.py`, RAG tooling, etc.) are uploaded and kept in sync.
- **Auto-sync on every commit**: A Git post-commit hook runs `rag/sync_changed.py` → changed files are instantly updated in the collection.
- **Agentic RAG assistant**: `rag/ask_repo.py` lets Grok autonomously retrieve relevant chunks and generate detailed, proactive answers grounded in your current code.

### Example Capabilities
Ask questions like:
- “Walk me through adding GPU support: new EKS node group in Terraform, taints/tolerations, RayCluster worker specs, and vLLM considerations.”
- “If Ray worker pods are pending, what are the likely causes based on current infra and manifests?”
- “Propose improvements to serve_demo.py for multi-GPU distributed serving.”

## Streamlit AI Co-Pilot Frontend 🚀

A beautiful, local Streamlit app has been added as the primary interface for interacting with the RAG-powered repo assistant.

### Features
- **Live chat interface** with full conversation history
- **Premium dark-mode styling** — Inter font, framed answers, highlighted code blocks
- **Session persistence** — chat history survives app restarts
- **Selective deletion** — remove unwanted Q&A pairs with a single click
- **Simple & focused** — no sidebar clutter, maximum space for insights

### Python Environment Setup

```bash
# Create and activate venv
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up .env (copy from .env.example)
cp .env.example .env
# Edit .env with your xAI API keys and collection ID

# Run the AI co-pilot
streamlit run rag/frontend/app.py
```
