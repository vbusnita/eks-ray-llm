# EKS + Ray + vLLM Inference Cluster (Learning Project)

Real-world grind to run production-grade LLM inference on Amazon EKS.

**Status (Dec 21, 2025)**: Cluster live on CPU (m5.large) via eksctl pivot. GPU quota pending.

## Goal
Deploy vLLM on Ray Serve in EKS — scalable, cost-aware LLM inference.

## The Reality (2025 EKS Pain Points)
- New AWS account → 0 vCPU quota for G/P instances (GPU blocked)
- Spot quota also 0 → Spot failed
- AL2 AMI deprecated Nov 26, 2025 → "unhealthy nodes"
- AL2023 template bugs in Terraform modules
- Bottlerocket health check timing issues

**Current pivot**: m5.large CPU node for immediate inference while waiting for GPU quota.

## Architecture
- VPC with private/public subnets + NAT
- EKS 1.30 cluster
- Managed node group (m5.large CPU → GPU when quota approved)
- KubeRay operator → RayCluster → RayService + vLLM

## Setup

## Quick CPU Cluster (eksctl — current working path)
```bash
eksctl create cluster \
  --name ray-llm-demo \
  --region us-east-1 \
  --version 1.30 \
  --nodegroup-name worker \
  --node-type m5.large \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 2 \
  --profile terraform-local