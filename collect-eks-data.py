#!/usr/bin/env python3
import subprocess
import json

CLUSTER_NAME = "ray-llm-demo"
REGION = "us-east-1"
PROFILE = "terraform-local"  # Your IAM profile

def run_cmd(cmd):
    full_cmd = ["aws", "--profile", PROFILE, "--region", REGION] + cmd
    try:
        return subprocess.run(full_cmd, capture_output=True, text=True, check=True).stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stderr.strip()}"

data = {}

# Cluster description
data["cluster"] = json.loads(run_cmd(["eks", "describe-cluster", "--name", CLUSTER_NAME]) or "{}")

# Node groups
node_groups = json.loads(run_cmd(["eks", "list-nodegroups", "--cluster-name", CLUSTER_NAME, "--query", "nodegroups"]) or "[]")
data["node_groups"] = {}
for ng in node_groups:
    data["node_groups"][ng] = json.loads(run_cmd(["eks", "describe-nodegroup", "--cluster-name", CLUSTER_NAME, "--nodegroup-name", ng]) or "{}")

# Add-ons
add_ons = ["vpc-cni", "kube-proxy", "coredns"]
data["add_ons"] = {}
for add_on in add_ons:
    data["add_ons"][add_on] = json.loads(run_cmd(["eks", "describe-addon", "--cluster-name", CLUSTER_NAME, "--addon-name", add_on]) or "{}")

# IAM roles
cluster_role = data["cluster"].get("cluster", {}).get("roleArn", "")
data["cluster_role"] = json.loads(run_cmd(["iam", "get-role", "--role-name", cluster_role.split('/')[-1]]) or "{}")
data["cluster_policies"] = json.loads(run_cmd(["iam", "list-attached-role-policies", "--role-name", cluster_role.split('/')[-1], "--query", "AttachedPolicies"]) or "[]")

node_role = data["node_groups"].get(node_groups[0], {}).get("nodegroup", {}).get("nodeRole", "")
data["node_role"] = json.loads(run_cmd(["iam", "get-role", "--role-name", node_role.split('/')[-1]]) or "{}")
data["node_policies"] = json.loads(run_cmd(["iam", "list-attached-role-policies", "--role-name", node_role.split('/')[-1], "--query", "AttachedPolicies"]) or "[]")

# VPC, subnets, SGs
vpc_id = data["cluster"].get("cluster", {}).get("resourcesVpcConfig", {}).get("vpcId", "")
data["vpc"] = json.loads(run_cmd(["ec2", "describe-vpcs", "--vpc-ids", vpc_id]) or "{}")

subnet_ids = data["cluster"].get("cluster", {}).get("resourcesVpcConfig", {}).get("subnetIds", [])
data["subnets"] = json.loads(run_cmd(["ec2", "describe-subnets", "--subnet-ids"] + subnet_ids) or "{}")

sg_ids = data["cluster"].get("cluster", {}).get("resourcesVpcConfig", {}).get("securityGroupIds", [])
data["security_groups"] = json.loads(run_cmd(["ec2", "describe-security-groups", "--group-ids"] + sg_ids) or "{}")

# Launch template
lt_id = data["node_groups"].get(node_groups[0], {}).get("nodegroup", {}).get("launchTemplate", {}).get("id", "")
data["launch_template"] = json.loads(run_cmd(["ec2", "describe-launch-templates", "--launch-template-ids", lt_id]) or "{}")

# Dump to file
with open("eks-data-dump.json", "w") as f:
    json.dump(data, f, indent=2)

print("Data dumped to eks-data-dump.json")