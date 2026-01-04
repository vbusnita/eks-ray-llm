#!/bin/bash
set -e
cd ../infra

# Find the most recent deploy log directory
LOG_DIR=$(ls -td ../tools/logs/*/ 2>/dev/null | head -n1 | xargs basename)

if [ -z "$LOG_DIR" ]; then
  echo "No existing deploy log directory found. Creating new one."
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  LOG_DIR="../tools/logs/$TIMESTAMP"
  mkdir -p "$LOG_DIR"  
else
  echo "Reusing deploy log directory: $LOG_DIR"
fi

echo "Exporting kubectl logs"
echo "======================"
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver \
    --all-containers --tail=100 > "$LOG_DIR/csi-logs.txt" 2>/dev/null || echo "No CSI pods" > "$LOG_DIR/csi-logs.txt"

kubectl describe pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver > "$LOG_DIR/csi-describe.txt" 2>/dev/null || echo "No CSI pods" > "$LOG_DIR/csi-describe.txt"

echo "Exporting CloudWatch logs (this may take a minute)"
echo "=================================================="

LOG_GROUP="/aws/eks/eks-ray-llm/cluster"

# Get all log stream names
STREAMS=$(aws logs describe-log-streams --log-group-name "$LOG_GROUP" \
    --query "logStreams[].logStreamName" --output text 2>/dev/null || echo "")

if [ -z "$STREAMS" ]; then
  echo "No log streams found or error accessing log group" > "$LOG_DIR/cloudwatch-logs.txt"
else
  > "$LOG_DIR/cloudwatch-logs.txt"  # Clear file
  for stream in $STREAMS; do
    echo "Fetching stream: $stream" | tee -a "$LOG_DIR/cloudwatch-logs.txt"
    aws logs get-log-events --log-group-name "$LOG_GROUP" \
        --log-stream-name "$stream" \
        --limit 1000 \
        --output text 2>/dev/null >> "$LOG_DIR/cloudwatch-logs.txt" || echo "Error fetching $stream" >> "$LOG_DIR/cloudwatch-logs.txt"
    echo "" >> "$LOG_DIR/cloudwatch-logs.txt"
  done
fi

echo "CloudWatch export complete"

echo
echo "💥 Destroying all resources..."
terraform destroy -auto-approve 2>&1 | tee "$LOG_DIR/terraform-destroy.log"

echo "✅ Destroy complete — all logs in $LOG_DIR"