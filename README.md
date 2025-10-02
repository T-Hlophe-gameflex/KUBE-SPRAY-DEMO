# Kubernetes ELK Stack Demo Platform

Production-ready Kubernetes deployment featuring comprehensive logging and observability using the ELK Stack (Elasticsearch, Logstash, Kibana) with microservices architecture.

## Features

- **ELK Stack v8.10.4** - Complete centralized logging solution
  - Elasticsearch for log storage and search
  - Logstash for log processing and enrichment
  - Kibana for visualization and analytics
  - Filebeat DaemonSet for cluster-wide log collection

- **Microservices Architecture** - Business services with inter-service communication
  - Order Service with structured logging
  - User Service with database integration
  - PostgreSQL database layer

- **Infrastructure as Code**
  - Ansible playbooks for lifecycle management
  - Organized Kubernetes manifests
  - Kind-based local development
  - Kubespray-ready for production deployment

- **Multi-Namespace Organization**
  - `monitoring` - ELK stack and observability
  - `backend` - Business logic services
  - `database` - Data layer (PostgreSQL)
  - `system` - Infrastructure components (Filebeat)

## Quick Start

### Local Development Deployment

1. **Deploy complete stack**
   ```bash
   ./scripts/deploy.sh
   ```

2. **Access Kibana dashboard**
   ```bash
   kubectl port-forward svc/kibana 5601:5601 -n monitoring
   # Open http://localhost:5601
   ```

3. **Generate sample logs**
   ```bash
   ./scripts/generate-sample-logs.sh 50
   ```

### Using Ansible Playbooks

```bash
# Deploy using Ansible
ansible-playbook playbooks/main.yml -e action=deploy

# Validate cluster health
ansible-playbook playbooks/main.yml -e action=validate

# Remove all applications
ansible-playbook playbooks/main.yml -e action=remove
```

### Alternative Deployment Methods

```bash
# Quick start with validation
./scripts/quick-start.sh

# Manual Kibana port-forward
./scripts/deploy.sh kibana

# Clean up cluster
./scripts/deploy.sh clean
```

## Production Deployment

For production use with real infrastructure using Kubespray:

```bash
# 1. Configure your inventory
cp inventory/mycluster/hosts.yaml.example inventory/mycluster/hosts.yaml
# Edit with your server IPs (6 nodes: 3 control-plane + 3 workers)

# 2. Deploy Kubernetes cluster
cd kubespray
ansible-playbook -i ../inventory/mycluster/hosts.yaml cluster.yml

# 3. Deploy applications to production cluster
kubectl apply -f k8s-manifests/
```

## Prerequisites

### Local Development

- **Docker** - Container runtime
- **kind** - Kubernetes in Docker for local clusters
- **kubectl** - Kubernetes CLI tool
- **Python 3.8+** - For Ansible and scripts

### Production Deployment (Optional)

- **Ansible 2.12+** - For Kubespray deployment
- **6 Ubuntu servers** - 3 control-plane + 3 worker nodes
- **SSH access** - Configured to all nodes

### Installation

```bash
# Install Python dependencies
pip install -r requirements.txt

# Install Ansible collections (for production)
ansible-galaxy collection install kubernetes.core
```

## Repository Structure

```text
├── k8s-manifests/          # Organized Kubernetes manifests
│   ├── observability/      # ELK stack (Elasticsearch, Logstash, Kibana)
│   ├── business-services/  # Microservices (order-service, user-service)
│   ├── data-layer/         # PostgreSQL database
│   ├── infrastructure/     # Filebeat DaemonSet
│   └── namespaces.yaml     # Namespace definitions
├── playbooks/              # Ansible automation
│   ├── main.yml           # Main orchestration playbook
│   ├── deploy-apps.yml    # Application deployment
│   ├── validate-cluster.yml # Cluster validation
│   └── remove-apps.yml    # Application removal
├── scripts/               # Deployment scripts
│   ├── deploy.sh          # Main deployment script
│   ├── quick-start.sh     # Quick start with validation
│   └── generate-sample-logs.sh # Log generation for testing
├── inventory/             # Kubespray inventory configuration
│   └── mycluster/        # Cluster topology and settings
├── kubespray/            # Kubespray submodule for production
└── requirements.txt      # Python dependencies
```

## Architecture

### ELK Stack Flow

```text
Applications → Filebeat (DaemonSet) → Logstash → Elasticsearch → Kibana
```

- **Filebeat**: Collects logs from all pods across all namespaces
- **Logstash**: Processes logs, adds Kubernetes metadata, classifies by service
- **Elasticsearch**: Stores logs with daily indices
- **Kibana**: Provides visualization and search interface

### Microservices

- **Order Service** (Port 8080): Order management with structured logging
- **User Service** (Port 8081): User management with database integration
- **PostgreSQL**: Database layer with multiple databases

## Access Services

### Kibana Dashboard

```bash
kubectl port-forward svc/kibana 5601:5601 -n monitoring
# Open http://localhost:5601
```

### Order Service

```bash
kubectl port-forward svc/order-service 8080:8080 -n backend

# Create order
curl -X POST http://localhost:8080/orders \
  -H 'Content-Type: application/json' \
  -d '{"item":"laptop","quantity":1}'
```

### User Service

```bash
kubectl port-forward svc/user-service 8081:8081 -n backend

# Health check
curl http://localhost:8081/health
```

## Documentation

Each directory contains detailed README files:

- **[k8s-manifests/observability/README.md](k8s-manifests/observability/README.md)** - ELK stack configuration and usage
- **[k8s-manifests/business-services/README.md](k8s-manifests/business-services/README.md)** - Microservices architecture
- **[k8s-manifests/data-layer/README.md](k8s-manifests/data-layer/README.md)** - Database configuration
- **[k8s-manifests/infrastructure/README.md](k8s-manifests/infrastructure/README.md)** - Filebeat and log collection
- **[playbooks/README.md](playbooks/README.md)** - Ansible automation patterns
- **[scripts/README.md](scripts/README.md)** - Deployment scripts documentation
- **[inventory/README.md](inventory/README.md)** - Kubespray inventory and cluster topology

## Troubleshooting

### Cluster Not Starting

```bash
# Check kind clusters
kind get clusters

# Recreate cluster
kind delete cluster --name kubespray-ansi-cluster
./scripts/deploy.sh
```

### Pods Not Ready

```bash
# Check pod status
kubectl get pods --all-namespaces

# Check specific pod logs
kubectl logs <pod-name> -n <namespace>
```

### Kibana Not Accessible

```bash
# Check Kibana pod
kubectl get pods -n monitoring -l app=kibana

# Check Kibana logs
kubectl logs -n monitoring deployment/kibana
```

## Cleanup

```bash
# Delete cluster and all resources
kind delete cluster --name kubespray-ansi-cluster

# Or use deploy script
./scripts/deploy.sh clean
```

## License

This project is for demonstration purposes.
