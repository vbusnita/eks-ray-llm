# random.tf: Generates unique identifiers for resource names and tags

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "random_uuid" "deployment_id" {
  count = var.deployment_id == "" ? 1 : 0
}

locals {
  deployment_id = var.deployment_id != "" ? var.deployment_id : random_uuid.deployment_id[0].result
}