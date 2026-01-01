#!/bin/bash
set -e
cd ../infra
echo "💥 Destroying all resources (no prompt)..."
terraform destroy -auto-approve

echo "✅ Destroy complete — clean slate!"
