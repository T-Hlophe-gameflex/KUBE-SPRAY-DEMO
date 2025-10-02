#!/bin/bash

# Quick Start Script for Kubernetes Microservices with ELK Stack
# This script provides a one-command deployment with validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-flight checks
print_info "Running pre-flight checks..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker and try again."
    exit 1
fi

if ! docker ps &> /dev/null; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi
print_success "Docker is running"

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl and try again."
    exit 1
fi
print_success "kubectl is installed"

# Check kind
if ! command -v kind &> /dev/null; then
    print_error "kind is not installed. Please install kind and try again."
    exit 1
fi
print_success "kind is installed"

# Check disk space
AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "${AVAILABLE_SPACE%.*}" -lt 10 ]; then
    print_warning "Low disk space detected. Recommended: 20GB+, Available: ${AVAILABLE_SPACE}G"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_success "Pre-flight checks passed!"
echo ""

# Deploy using main script
print_info "Starting deployment..."
./scripts/deploy.sh

# Wait for all pods to be ready
print_info "Waiting for all pods to be ready..."
sleep 30

# Check Elasticsearch
print_info "Checking Elasticsearch..."
kubectl wait --for=condition=ready pod -l app=elasticsearch -n monitoring --timeout=300s || print_warning "Elasticsearch not ready yet"

# Check Kibana
print_info "Checking Kibana..."
kubectl wait --for=condition=ready pod -l app=kibana -n monitoring --timeout=300s || print_warning "Kibana not ready yet"

# Check Logstash
print_info "Checking Logstash..."
kubectl wait --for=condition=ready pod -l app=logstash -n monitoring --timeout=300s || print_warning "Logstash not ready yet"

# Display status
echo ""
print_success "Deployment completed!"
echo ""

# Show pod status
print_info "Current pod status:"
kubectl get pods --all-namespaces

echo ""
print_info "To access Kibana, run:"
echo "  kubectl port-forward -n monitoring svc/kibana 5601:5601"
echo "  Then open http://localhost:5601 in your browser"

echo ""
print_info "First-time Kibana setup:"
echo "  1. Go to Stack Management → Data Views"
echo "  2. Create data view with pattern: k8s-logs-*"
echo "  3. Set time field: @timestamp"
echo "  4. Go to Discover to view logs"

echo ""
print_success "Quick start completed successfully!"
