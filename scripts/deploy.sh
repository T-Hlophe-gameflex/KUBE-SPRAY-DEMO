#!/bin/bash
set -e

echo "Kubernetes Logging Platform Deployment"
echo "========================================"

cluster_exists() {
    kind get clusters | grep -q "kubespray-ansi-cluster" 2>/dev/null
}

wait_for_deployment() {
    local namespace=$1
    local deployment=$2
    echo "Waiting for $deployment in $namespace..."
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace > /dev/null 2>&1
}

setup_cluster() {
    if cluster_exists; then
        echo "[OK] Cluster kubespray-ansi-cluster already exists"
    else
        echo "Creating kind cluster..."
        cat > /tmp/kind-config.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kubespray-ansi-cluster
nodes:
- role: control-plane
  image: kindest/node:v1.28.0
- role: worker
  image: kindest/node:v1.28.0
- role: worker
  image: kindest/node:v1.28.0
EOF
        kind create cluster --config=/tmp/kind-config.yaml
        rm -f /tmp/kind-config.yaml
        echo "[OK] Cluster created"
    fi
}

deploy_logging() {
    echo "Deploying logging architecture..."
    
    kubectl apply -f k8s-manifests/namespaces.yaml
    echo "[OK] Namespaces created"
    
    kubectl apply -f k8s-manifests/data-layer/
    wait_for_deployment "database" "postgres"
    echo "[OK] Data layer deployed"
    
    echo "Deploying observability stack..."
    
    # Deploy Elasticsearch
    kubectl apply -f k8s-manifests/observability/elasticsearch/
    wait_for_deployment "monitoring" "elasticsearch"
    echo "[OK] Elasticsearch deployed"
    
    echo "Initializing Elasticsearch (0 replicas, removing sample data)..."
    kubectl wait --for=condition=complete --timeout=120s job/elasticsearch-init -n monitoring 2>/dev/null || echo "Init job already completed or failed"
    echo "[OK] Elasticsearch initialized"
    
    # Deploy Logstash with config from file
    echo "Deploying Logstash configuration..."
    kubectl create configmap logstash-config \
      --from-file=logstash.conf=k8s-manifests/observability/logstash/pipeline.conf \
      -n monitoring --dry-run=client -o yaml | kubectl apply -f - > /dev/null 2>&1
    kubectl apply -f k8s-manifests/observability/logstash/
    wait_for_deployment "monitoring" "logstash"
    echo "[OK] Logstash deployed"
    
    # Deploy Kibana
    kubectl apply -f k8s-manifests/observability/kibana/
    wait_for_deployment "monitoring" "kibana"
    echo "[OK] Kibana deployed"
    
    # Deploy Filebeat
    kubectl apply -f k8s-manifests/observability/filebeat/
    echo "[OK] Filebeat deployed"
    
    echo "[OK] Observability stack deployed"
    
    kubectl apply -f k8s-manifests/infrastructure/
    echo "[OK] Infrastructure deployed"
    
    kubectl apply -f k8s-manifests/business-services/
    wait_for_deployment "backend" "order-service"
    wait_for_deployment "backend" "user-service"
    echo "[OK] Business services deployed"
}

show_access() {
    echo ""
    echo "Access Services"
    echo "=================="
    echo "Kibana Dashboard:"
    echo "  kubectl port-forward svc/kibana 5601:5601 -n monitoring &"
    echo "  http://localhost:5601"
    echo ""
    echo "Index Patterns to Create in Kibana:"
    echo "  - kubespray-logs-* (consolidated view of all logs)"
    echo "  - kubernetes-logs-* (all namespace-specific logs)"
    echo "  - kubernetes-logs-monitoring-* (monitoring namespace only)"
    echo "  - kubernetes-logs-backend-* (backend namespace only)"
    echo ""
    echo "Order Service:"
    echo "  kubectl port-forward svc/order-service 8080:8080 -n backend &"
    echo "  curl -X POST http://localhost:8080/orders -H 'Content-Type: application/json' -d '{\"item\":\"test\"}'"
    echo ""
    echo "User Service:"
    echo "  kubectl port-forward svc/user-service 8081:8081 -n backend &"
    echo "  curl http://localhost:8081/health"
    echo ""
    echo "PostgreSQL Database:"
    echo "  kubectl port-forward svc/postgresql 5432:5432 -n database &"
    echo "  psql -h localhost -p 5432 -U postgres"
}

start_kibana() {
    echo "Starting Kibana access..."
    kubectl port-forward svc/kibana 5601:5601 -n monitoring > /dev/null 2>&1 &
    KIBANA_PID=$!
    echo "[OK] Kibana available at: http://localhost:5601"
    echo "Kibana PID: $KIBANA_PID (use 'kill $KIBANA_PID' to stop)"
}

case "${1:-deploy}" in
    "setup")
        setup_cluster
        ;;
    "deploy")
        setup_cluster
        deploy_logging
        show_access
        ;;
    "kibana")
        start_kibana
        ;;
    "access")
        show_access
        ;;
    "clean")
        kind delete cluster --name kubespray-ansi-cluster
        echo "[OK] Cluster deleted"
        ;;
    *)
        echo "Usage: $0 [setup|deploy|kibana|access|clean]"
        echo ""
        echo "Commands:"
        echo "  setup   - Create kind cluster only"
        echo "  deploy  - Setup cluster and deploy everything (default)"
        echo "  kibana  - Start Kibana port-forward"
        echo "  access  - Show access commands"
        echo "  clean   - Delete cluster"
        exit 1
        ;;
esac
