#!/bin/bash

# Clean Elasticsearch indices and configure for 0 replicas
# This script removes sample data and sets up clean indices

set -e

echo "Elasticsearch Cleanup and Configuration"
echo "========================================"

# Check if Elasticsearch is accessible
if ! kubectl get deployment elasticsearch -n monitoring &>/dev/null; then
    echo "Error: Elasticsearch is not deployed"
    exit 1
fi

echo "Waiting for Elasticsearch to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/elasticsearch -n monitoring

echo ""
echo "Running cleanup and configuration..."

# Run cleanup commands via kubectl exec
kubectl exec -n monitoring deployment/elasticsearch -- curl -X DELETE "http://localhost:9200/kibana_sample_*" 2>/dev/null || echo "No Kibana sample data found"

echo ""
echo "Setting all indices to 0 replicas..."
kubectl exec -n monitoring deployment/elasticsearch -- curl -X PUT "http://localhost:9200/*/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index": {"number_of_replicas": 0}}' 2>/dev/null

echo ""
echo "Creating index template for kubernetes-logs with 0 replicas..."
kubectl exec -n monitoring deployment/elasticsearch -- curl -X PUT "http://localhost:9200/_index_template/kubernetes-logs-template" \
  -H 'Content-Type: application/json' \
  -d '{
    "index_patterns": ["kubernetes-logs-*"],
    "priority": 500,
    "template": {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "refresh_interval": "5s"
      }
    }
  }' 2>/dev/null

echo ""
echo "Creating index template for kubespray-logs (consolidated) with 0 replicas..."
kubectl exec -n monitoring deployment/elasticsearch -- curl -X PUT "http://localhost:9200/_index_template/kubespray-logs-template" \
  -H 'Content-Type: application/json' \
  -d '{
    "index_patterns": ["kubespray-logs-*"],
    "priority": 500,
    "template": {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "refresh_interval": "5s"
      }
    }
  }' 2>/dev/null

echo ""
echo "Current indices:"
kubectl exec -n monitoring deployment/elasticsearch -- curl -s "http://localhost:9200/_cat/indices?v" 2>/dev/null

echo ""
echo "Cluster health:"
kubectl exec -n monitoring deployment/elasticsearch -- curl -s "http://localhost:9200/_cluster/health?pretty" 2>/dev/null | grep -E "(status|number_of|unassigned)"

echo ""
echo "Cleanup complete!"
echo ""
echo "To generate sample logs: ./scripts/generate-sample-logs.sh 50"
echo "To access Kibana: make logs"
