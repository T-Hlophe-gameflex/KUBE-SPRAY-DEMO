# Infrastructure

This folder contains system-level components and utilities that support the entire Kubernetes cluster.

## Components

### Filebeat (`filebeat.yaml`)

- **Purpose**: Log collection agent deployed as DaemonSet
- **Namespace**: `infrastructure`
- **Deployment**: Runs on every cluster node
- **Features**:
  - Multi-namespace log collection
  - Kubernetes metadata enrichment
  - Automatic service discovery
  - JSON and multiline log parsing
  - Performance optimization

### Filebeat Configuration (`filebeat-configmap.yaml`)

- **Purpose**: Filebeat configuration and parsing rules
- **Contains**:
  - Kubernetes autodiscovery rules
  - Log parsing patterns
  - Output configuration to Logstash
  - Performance tuning settings

### RBAC Permissions (`filebeat-rbac.yaml`)

- **Purpose**: Role-based access control for Filebeat
- **Contains**:
  - ServiceAccount for Filebeat pods
  - ClusterRole with necessary permissions
  - ClusterRoleBinding for access

## Deployment

```bash
# Deploy all infrastructure components
kubectl apply -f infrastructure/

# Verify DaemonSet deployment
kubectl get ds -n infrastructure
kubectl get pods -n infrastructure
```

## Monitoring

```bash
# Check Filebeat status on all nodes
kubectl get pods -n infrastructure -o wide

# View Filebeat logs
kubectl logs -n infrastructure ds/filebeat

# Check Filebeat configuration
kubectl describe configmap filebeat-config -n infrastructure
```

## Log Collection

### Collection Scope

Filebeat collects logs from:

- **All Namespaces**: Comprehensive cluster-wide log collection
- **Pod Logs**: Application and system pod logs
- **Container Logs**: Individual container log streams
- **System Logs**: Node-level system logs

### Processing Features

- **Namespace Tagging**: Automatic namespace identification
- **Service Classification**: Service group categorization
- **Metadata Enrichment**: Kubernetes labels and annotations
- **Multiline Parsing**: Stack traces and multi-line logs
- **JSON Parsing**: Structured log extraction

### Output Destination

All collected logs are sent to:
- **Target**: Logstash service in `observability` namespace
- **Port**: 5044 (Beats input)
- **Protocol**: Beats protocol with compression

## Configuration

### Resource Management

- **Memory**: 200Mi limit per Filebeat pod
- **CPU**: 100m limit for log processing
- **Disk**: Access to host filesystem for log reading

### Security

- **ServiceAccount**: Dedicated service account for Filebeat
- **RBAC**: Minimal required permissions for log access
- **Host Access**: Read-only access to container logs

### Performance

- **Harvester Limit**: Controlled number of active harvesters
- **Buffer Settings**: Optimized for high-throughput logging
- **Compression**: Efficient log transmission

## Permissions

Filebeat requires the following permissions:

- **Pods**: List, get, and watch pod information
- **Nodes**: Access to node metadata
- **Namespaces**: List and watch namespace changes
- **ConfigMaps**: Read configuration updates
- **Secrets**: Access to authentication credentials (if needed)

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Node 1        │    │   Node 2        │    │   Node 3        │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │ Filebeat  │  │    │  │ Filebeat  │  │    │  │ Filebeat  │  │
│  │ DaemonSet │  │    │  │ DaemonSet │  │    │  │ DaemonSet │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Logstash      │
                    │ (observability) │
                    └─────────────────┘
```

This ensures comprehensive log collection from every node in the cluster.