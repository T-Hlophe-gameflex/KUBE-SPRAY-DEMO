# Deployment Scripts

This directory contains automation scripts for deploying and managing the Kubernetes cluster and applications.

## Available Scripts

### 1. deploy.sh

Main deployment script for setting up the complete Kubernetes environment with ELK stack.

**Usage:**
```bash
# Full deployment (cluster + all services)
./deploy.sh

# Deploy only ELK stack (assumes cluster exists)
./deploy.sh --elk-only

# Deploy only applications (assumes cluster exists)
./deploy.sh --apps-only

# Clean up everything
./deploy.sh --cleanup
```

**Features:**
- Creates Kind cluster if not exists
- Deploys all namespaces
- Deploys data layer (PostgreSQL database)
- Deploys business services (order-service, user-service)
- Deploys ELK stack (Elasticsearch, Logstash, Kibana)
- Deploys infrastructure components (Filebeat)
- Validates deployment status
- Provides access instructions

### 2. generate-sample-logs.sh

Generate sample log entries for testing the ELK stack.

**Usage:**
```bash
./generate-sample-logs.sh
```

## Common Operations

### Deploy Everything
```bash
./deploy.sh
```

### Check Status
```bash
kubectl get pods --all-namespaces
```

### Access Kibana
```bash
kubectl port-forward -n monitoring svc/kibana 5601:5601
# Open http://localhost:5601
```

### Clean Up
```bash
./deploy.sh --cleanup
kind delete cluster --name kubespray-ansi-cluster
```

---

**Last Updated**: October 2, 2025
