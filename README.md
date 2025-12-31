# EKS-Ray-LLM: My Training Ground for AI Infrastructure Mastery

This repo is my personal training ground for learning and experimenting with AI infrastructure. As a SysAdmin in my 40s with limited knowledge of AI infra but a strong curiosity, I'm using it to build skills in EKS (Kubernetes on AWS), Ray (for distributed AI workloads), and LLM inference with vLLM. What you see here was built in about a week using Grok (xAI's AI) as a guide, through trial-and-error "vibe coding" (implement, break, fix, learn). Now, I'm iterating to level up in areas like Terraform, debugging, and integrating AI systems—aiming for a robust, scalable setup.

This isn't production-ready yet, but it's a work-in-progress that demonstrates my hands-on approach. For recruiters: It showcases how I learn by doing, with a clear master plan below to guide my growth.


## Repository Structure
```bash
eks-ray-llm/
├── README.md                    # This file – victory log + guide
├── collect-eks-data.py          # Original eksctl data dumper
├── eks-data-dump.json           # Reference from working eksctl cluster
├── infra/                       # Terraform (EKS + VPC + IAM + SECURITY)
│   ├── main.tf
│   ├── eks.tf
│   ├── iam.tf
│   ├── security.tf
│   ├── backend.tf              # State management
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

## Quick Setup Guide

1. **Prerequisites**: AWS account with CLI configured, Terraform, kubectl, Helm.

2. **Deploy Infrastructure**:
   ```bash
   cd infra
   terraform init
   terraform plan
   terraform apply

```bash
# Update Kubeconfig
aws eks update-kubeconfig --name ray-llm-demo --region us-east-1 --profile your-profile

# Install KubeRay Operator
helm install kuberay-operator kuberay/kuberay-operator --namespace kuberay --create-namespace --version 1.2.0

# Deploy RayCluster
kubectl apply -f ../manifests/ray-cluster-cpu.yaml

# Access Ray Dashboard
kubectl port-forward svc/ray-cluster-cpu-head-svc 8265:8265
open http://localhost:8265
```

## RAG Features: Install deps and run the Streamlit app for repo querying

```bash
python -m venv venv
source venv/bin/activate  # Or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env  # Add xAI API keys
streamlit run rag/frontend/app.py
```

# Master Plan: Roadmap for Leveling Up

This is my structured plan to evolve the repo from basic to advanced, building key skills along the way. I'll track progress via commits and issues. Each phase focuses on 1-2 weeks of part-time work (5-10 hours/week) to fit family life.

## Phase 1: Polish Basics (Current Focus - Q1 2026)

- Goals: Add testing, CI/CD, and documentation.
- Skills to Build: Unit testing (pytest), GitHub Actions, modular Terraform.

- Tasks:
  - Add pytest tests for Python scripts (e.g., serve_demo.py, ask_repo.py).
  - Set up GitHub Actions for linting (flake8, tfsec) and auto-deploys.
  - Refactor Terraform into reusable modules; add variables for customization.

- Why?: Ensures reliability; shows attention to quality in interviews.

## Phase 2: Add GPU and Scaling (Q1 2026)

- Goals: Enable GPU inference and autoscaling.
- Skills to Build: AWS node groups, K8s taints/tolerations, HPA/Cluster Autoscaler.

- Tasks:
  - Create GPU node group in Terraform (e.g., g4dn instances).
  - Update Ray manifests for GPU support; test vLLM inference on models like Llama.
  - Integrate autoscaling for Ray workers based on load.

- Why?: Makes it real for ML workloads; demonstrates scaling expertise.

## Phase 3: Monitoring and Security (Q2 2026)

- Goals: Harden security and add observability.
- Skills to Build: IRSA, network policies, Prometheus/Grafana.

- Tasks:
  - Enable IRSA for pods; use Secrets Manager for keys.
  - Add Prometheus for Ray metrics; set up dashboards.
  - Implement vulnerability scanning (Trivy) in CI.

- Why?: Production-readiness; highlights security mindset.

## Phase 4: Advanced AI Features and Innovation (Q2-Q3 2026)

- Goals: Enhance RAG and add novel elements.
- Skills to Build: Embeddings, agentic AI, benchmarks.

- Tasks:
  - Improve RAG with chunking/embeddings (e.g., FAISS).
  - Add agentic automation: Grok-generated code patches via PRs.
  - Run benchmarks (vLLM vs. baselines); contribute to upstream if possible.

- Why?: Shows creativity; turns repo into a unique portfolio piece.

## Phase 5: Optimization and Community (Ongoing)

- Goals: Cost/efficiency tweaks; share learnings.
- Skills to Build: Spot Instances, multi-AZ, networking.

- Tasks:
  - Optimize costs (e.g., Spot nodes); add multi-region support.
  - Document failures in a "Lessons Learned" file.

- Why?: Keeps the infra efficient and resilient.