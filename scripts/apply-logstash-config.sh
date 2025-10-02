#!/bin/bash
# Apply Logstash configuration from external pipeline.conf file
# This creates/updates the ConfigMap from the separate configuration file

set -e

PIPELINE_FILE="k8s-manifests/observability/logstash/pipeline.conf"
NAMESPACE="monitoring"
CONFIGMAP_NAME="logstash-config"

if [ ! -f "$PIPELINE_FILE" ]; then
    echo "Error: Pipeline file not found: $PIPELINE_FILE"
    exit 1
fi

echo "Applying Logstash configuration from $PIPELINE_FILE..."
echo ""

# Create ConfigMap from file
kubectl create configmap "$CONFIGMAP_NAME" \
  --from-file=logstash.conf="$PIPELINE_FILE" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "✅ ConfigMap '$CONFIGMAP_NAME' updated in namespace '$NAMESPACE'"
echo ""
echo "To apply changes to running Logstash:"
echo "  kubectl rollout restart deployment/logstash -n $NAMESPACE"
echo ""
read -p "Restart Logstash now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl rollout restart deployment/logstash -n "$NAMESPACE"
    echo "✅ Logstash is restarting with new configuration"
else
    echo "Skipped restart. Run manually when ready:"
    echo "  kubectl rollout restart deployment/logstash -n $NAMESPACE"
fi
