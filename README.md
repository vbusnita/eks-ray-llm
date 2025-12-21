# EKS + Ray + vLLM Inference Cluster (Learning Project)

Real-world attempt to run production-grade LLM inference on EKS.

**Status**: Cluster provisioning in progress (m5.large CPU pivot while GPU quota pending).

## Goal
Run vLLM on Ray Serve in EKS — scalable, cost-controlled LLM inference.

## Current Challenges (Dec 2025 Reality)
- New AWS account → 0 vCPU quota for G/P instances (GPU)
- Spot quota also 0 → Spot failed
- AL2 AMI deprecated Nov 26, 2025 → "unhealthy nodes" failures
- AL2023 template bugs in older EKS modules
- Bottlerocket health check timing issues

**Current pivot**: m5.large CPU node for immediate progress.

## Tools Built Along the Way
- `aws-cost-estimator` repo: Live cost watcher with:
  - Real-time dashboard
  - Session + lifetime tracking
  - Dead-man switch ($5 + 30m idle → auto destroy)
  - Tested Python script
- `aws-live-eks-provision-dashboard` repo: Live EKS provisioning dashboard

## Architecture
- VPC with private/public subnets + NAT
- EKS 1.30 cluster
- Managed node group (m5.large CPU, switching to GPU when quota approved)
- KubeRay operator → RayCluster → RayService + vLLM

## Setup
```bash
cd infra
terraform init
terraform apply
```

## Monitoring
- Cost watcher
```bash
./live-eks-cost-watcher.py
```
- Provisioning dashboard
```bash
./live-eks-provision-dashboard.py
```