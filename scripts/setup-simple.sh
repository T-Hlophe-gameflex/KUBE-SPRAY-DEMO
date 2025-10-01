#!/bin/bash
set -e

echo "🚀 Kubernetes Demo Setup"
echo "======================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Creating kind cluster..."
cat > "${PROJECT_ROOT}/simple-kind-config.yaml" << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kubespray-ansi-cluster
nodes:
- role: control-plane
  image: kindest/node:v1.28.0
  extraPortMappings:
  # Web app access
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
  # API access  
  - containerPort: 30081
    hostPort: 30081
    protocol: TCP
- role: worker
  image: kindest/node:v1.28.0
- role: worker
  image: kindest/node:v1.28.0
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/16"
EOF

# Delete existing cluster if it exists
echo -e "${YELLOW}🗑️  Cleaning up any existing cluster...${NC}"
kind delete cluster --name kubespray-ansi-cluster 2>/dev/null || true

# Create new cluster
echo "Creating cluster..."
kind create cluster --config="${PROJECT_ROOT}/simple-kind-config.yaml" --wait=300s

echo "Verifying cluster..."
kubectl cluster-info --context kind-kubespray-ansi-cluster
kubectl get nodes -o wide

echo "✅ Cluster ready!"
echo ""
echo "Deploy apps: ansible-playbook playbooks/main.yml -e action=deploy"
echo "Validate: ansible-playbook playbooks/main.yml -e action=validate"