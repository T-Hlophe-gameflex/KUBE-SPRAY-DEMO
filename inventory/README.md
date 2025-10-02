# Inventory Directory

## Overview

The `inventory/` directory contains Kubernetes cluster infrastructure definitions and configuration management for Kubespray deployments. This directory serves as the **infrastructure configuration layer**, defining target nodes, cluster topology, and operational parameters for both local development and production environments.

**Current Status**: This directory contains a **production-ready HA configuration** (6 nodes) while the **active demo cluster** runs on a **3-node kind cluster** for resource efficiency during development and demonstration.

## Purpose

The inventory system defines:

- **Target Infrastructure**: Which servers/nodes to use (currently configured for 6-node HA setup)
- **Cluster Topology**: Control plane and worker node distribution (3 masters + 3 workers)
- **Network Configuration**: Pod and service CIDR ranges (10.233.x.x/18)
- **Feature Sets**: Enabled Kubernetes features and add-ons (Calico CNI, CoreDNS)
- **Security Settings**: Authentication and authorization configurations (RBAC enabled)

## Directory Structure

```

inventory/
└── mycluster/                    # Cluster-specific configuration
    ├── hosts.yaml               # Node inventory and cluster topology
    └── group_vars/              # Configuration variables by node groups
        ├── all/                 # Global cluster settings
        └── k8s_cluster/         # Kubernetes-specific configurations
```

## Core Components

### hosts.yaml

**Purpose**: Defines cluster node inventory and topology

**Current Configuration**: Production-ready HA setup with 6 nodes:

```yaml
# Production HA Configuration (currently defined)
3 Control Plane Nodes:
  - k8s-master-01 (192.168.1.10) + etcd1
  - k8s-master-02 (192.168.1.11) + etcd2  
  - k8s-master-03 (192.168.1.12) + etcd3

3 Worker Nodes:
  - k8s-worker-01 (192.168.1.20)
  - k8s-worker-02 (192.168.1.21)
  - k8s-worker-03 (192.168.1.22)
```

**Active Demo Cluster**: 3-node kind cluster for development:

```bash
# Current Running Cluster (kind-based)
kubespray-ansi-cluster-control-plane (172.18.0.4) - Control Plane
kubespray-ansi-cluster-worker        (172.18.0.2) - Worker Node  
kubespray-ansi-cluster-worker2       (172.18.0.3) - Worker Node
```

**Key Features**:

- **High Availability**: 3 control plane nodes ensure 2/3 quorum majority
- **etcd Cluster**: 3-node etcd with stacked topology (co-located with masters)
- **Load Distribution**: 3 dedicated worker nodes for workload spreading
- **Fault Tolerance**: Survives single node failures without service interruption
- **Scalability**: Easy addition/removal of worker nodes

### group_vars/ Directory

**Purpose**: Hierarchical configuration management for different node groups

#### all/ - Global Settings

- **all.yml**: Base cluster configuration affecting all nodes
- **containerd.yml**: Container runtime configuration

#### k8s_cluster/ - Kubernetes Settings

- **k8s-cluster.yml**: Core Kubernetes cluster parameters
- **addons.yml**: Optional cluster add-ons and features
- **k8s-net-calico.yml**: Calico network plugin configuration

## Configuration Hierarchy

Kubespray follows a **hierarchical configuration model**:

1. **Default Values** (in Kubespray codebase)
2. **Group Variables** (inventory/mycluster/group_vars/)
3. **Host Variables** (inventory/mycluster/host_vars/)
4. **Extra Variables** (command line -e parameters)

Higher levels override lower levels, providing flexible configuration management.

## Network Architecture

### Network Configuration (Active)

Current demo cluster networking:

- **Pod CIDR**: 10.244.0.0/16 (kind default for 65,534 pods)
- **Service CIDR**: 10.96.0.0/12 (4,096 service IPs)
- **CNI Plugin**: kindnet (kind's simplified CNI)
- **DNS**: CoreDNS for service discovery

### Production Network Configuration (hosts.yaml ready)

Production cluster networking (when deployed with Kubespray):

- **Pod CIDR**: 10.233.64.0/18 (16,384 pod IPs)  
- **Service CIDR**: 10.233.0.0/18 (16,384 service IPs)
- **CNI Plugin**: Calico with BGP networking
- **DNS**: CoreDNS with advanced caching

### Network Features

- **Network Policies**: Micro-segmentation support
- **Load Balancing**: IPVS-based kube-proxy
- **Ingress**: Optional nginx ingress controller
- **Service Mesh**: Ready for Istio integration

## Cluster Topology Design

### Current Demo Setup (Active)

```text
Kind-based 3-Node Cluster (Resource Efficient)
1 Control Plane + 2 Workers = 3 Total Nodes

kubespray-ansi-cluster-control-plane (master)
├── kubespray-ansi-cluster-worker    (worker)  
└── kubespray-ansi-cluster-worker2   (worker)
```

- **Pros**: Low resource usage, fast startup, demo-friendly
- **Cons**: Single control plane point of failure
- **Use Case**: Development, testing, demonstration

### Production Configuration (Defined in hosts.yaml)

```text
HA 6-Node Cluster (Production Ready) 
3 Control Plane + 3 Workers = 6 Total Nodes

Control Plane (HA with etcd):
├── k8s-master-01 (192.168.1.10) + etcd1
├── k8s-master-02 (192.168.1.11) + etcd2  
└── k8s-master-03 (192.168.1.12) + etcd3

Worker Nodes (Workload Distribution):
├── k8s-worker-01 (192.168.1.20)
├── k8s-worker-02 (192.168.1.21)
└── k8s-worker-03 (192.168.1.22)
```

- **Pros**: High availability, fault tolerance, production-grade
- **Cons**: Higher resource requirements (6 VMs/machines)
- **Use Case**: Production deployments, mission-critical workloads

## Understanding the Inventory Configuration

### Dual-Purpose Setup

This inventory directory serves **two distinct purposes**:

#### 1. **Production Blueprint** (hosts.yaml)
The `hosts.yaml` file defines a **production-ready 6-node HA cluster** configuration:
- Ready for deployment with Kubespray on real infrastructure  
- Demonstrates enterprise-grade Kubernetes architecture patterns
- Shows proper control plane HA and worker node distribution
- Configured for 192.168.1.x network with dedicated server hardware

#### 2. **Development Context** (Current Active)  
The **active demo environment** runs on a simplified 3-node kind cluster:
- Provides the same application functionality with reduced resources
- Enables full ELK stack and multi-tier application demonstration  
- Uses Docker containers instead of VMs for accessibility
- Maintains identical namespace structure and service patterns

### Why This Approach?

**Educational Value**: Shows both development and production approaches
**Resource Efficiency**: Demo runs locally without requiring 6 VMs
**Scalability Demonstration**: Same applications work on both architectures  
**Real-World Relevance**: Production config reflects actual enterprise needs

### Configuration Mapping

| Component | Demo (kind) | Production (hosts.yaml) |
|-----------|-------------|-------------------------|
| **Control Plane** | 1 node | 3 nodes (HA) |
| **Workers** | 2 nodes | 3 nodes (dedicated) |  
| **etcd** | Single instance | 3-node cluster |
| **Networking** | kindnet | Calico BGP |
| **IP Range** | 10.244.x.x/16 | 10.233.x.x/18 |
| **Access** | Port-forward | LoadBalancer/Ingress |

### How Kubespray Works

Kubespray is a composition of **Ansible playbooks** that:

1. **Prepares Infrastructure**: Installs dependencies, configures OS
2. **Deploys etcd**: Sets up distributed key-value store
3. **Installs Control Plane**: API server, scheduler, controller manager
4. **Configures Workers**: kubelet, kube-proxy, container runtime
5. **Sets Up Networking**: CNI plugin and network policies
6. **Installs Add-ons**: DNS, monitoring, ingress controllers

### Deployment Process

```bash
ansible-playbook -i inventory/mycluster/hosts.yaml kubespray/cluster.yml
```

This command:

- Reads inventory configuration
- Applies group variables
- Executes Kubespray playbooks in sequence
- Validates cluster health

## Key Configuration Files

### all.yml - Global Settings

```yaml
kubeconfig_localhost: true          # Generate local kubeconfig
kubectl_localhost: true             # Install kubectl locally
cluster_name: kubespray-ansi        # Cluster identifier
```

### k8s-cluster.yml - Core Kubernetes

```yaml
kube_version: v1.28.0               # Kubernetes version
kube_network_plugin: calico         # CNI plugin
kube_proxy_mode: ipvs              # Load balancing mode
```

### addons.yml - Optional Features

```yaml
dns_mode: coredns                   # DNS provider
ingress_nginx_enabled: false       # Ingress controller
metallb_enabled: false             # Load balancer
```

## Integration with Project Components

### Current Demo Platform Integration

The inventory configuration integrates with our active multi-tier demonstration:

#### With k8s-manifests/ (Active Deployments)
- **Observability Stack**: ELK stack running on current 3-node cluster
- **Business Services**: User/Order services deployed across namespaces  
- **Data Layer**: PostgreSQL database with persistent storage
- **Infrastructure**: Filebeat DaemonSet collecting logs from all nodes

#### With scripts/ (Deployment Automation)
- **deploy.sh**: Uses current cluster context for automated deployment
- **Port Forwarding**: Scripts access services via cluster DNS
- **Health Checks**: Validates services running on active cluster nodes

#### Current Service Endpoints (Active)
```bash
# Accessible via port-forwarding on current cluster:
Kibana Dashboard:    http://localhost:5602
User Service API:    http://localhost:3001/health  
Order Service API:   http://localhost:3002/health
```

### Production Kubespray Integration (Ready for Deployment)

The hosts.yaml configuration is ready for full Kubespray deployment:

#### Target Infrastructure
- **Physical/Virtual Machines**: 6 Ubuntu servers with SSH access
- **Network**: 192.168.1.10-22 subnet with inter-node connectivity
- **Storage**: Local disks + optional network storage integration
- **Security**: SSH key authentication (id_rsa) configured

## Current Deployment Status

### Active Demo Cluster

The project is currently running on a **3-node kind cluster** for demonstration purposes:

```bash
# Verify current cluster
kubectl cluster-info
kubectl get nodes -o wide

# Check active namespaces and applications  
kubectl get pods --all-namespaces | grep -E "(observability|business|data)"
```

**Active Services:**
- **Elasticsearch**: Green cluster status (observability namespace)
- **Kibana**: Accessible at http://localhost:5602  
- **Logstash**: Processing logs with fixed configuration
- **Business Services**: User/Order services running across environments
- **PostgreSQL**: Database with active connections
- **Filebeat**: Log collection from all cluster nodes

### Production Deployment (Ready)

The hosts.yaml file is configured for production deployment with Kubespray:

**To Deploy Production Cluster:**

```bash
# 1. Prepare 6 Ubuntu servers with IPs 192.168.1.10-22
# 2. Configure SSH key access to all nodes
# 3. Update /etc/hosts with node mappings
# 4. Run Kubespray deployment:

cd kubespray
ansible-playbook -i ../inventory/mycluster/hosts.yaml cluster.yml
```

**Migration Path**: The current demo applications can be deployed to the production cluster using the same k8s-manifests/ without modification.

## Local Development vs Production

### Local (kind-based) - Current

- **Purpose**: Development, testing, and demonstration  
- **Nodes**: 3 Docker containers simulating Kubernetes nodes
- **Networking**: Docker bridge networks (10.244.x.x/16)
- **Storage**: EmptyDir and HostPath volumes
- **Access**: kubectl port-forward for service exposure
- **Resource Usage**: ~4GB RAM, minimal CPU for demo purposes

### Production (Kubespray-based) - Ready

- **Purpose**: Production workloads and enterprise deployment
- **Nodes**: 6 physical/virtual Ubuntu machines  
- **Networking**: Physical network with Calico CNI (10.233.x.x/18)
- **Storage**: Network-attached storage, cloud volumes, local SSDs
- **Access**: LoadBalancer services, Ingress controllers
- **Resource Usage**: Production-grade hardware requirements

## Security Considerations

### Authentication

- **API Server**: TLS certificates for all components
- **RBAC**: Role-based access control enabled
- **Service Accounts**: Pod-level authentication

### Network Security

- **Network Policies**: Micro-segmentation between namespaces
- **Encryption**: etcd data encrypted at rest
- **TLS**: All inter-component communication encrypted

## Operational Procedures

### Adding Worker Nodes

1. Update `hosts.yaml` with new node details
2. Run: `ansible-playbook -i inventory/mycluster/hosts.yaml kubespray/scale.yml`

### Removing Nodes

1. Update `hosts.yaml` to remove nodes
2. Run: `ansible-playbook -i inventory/mycluster/hosts.yaml kubespray/remove-node.yml`

### Upgrading Cluster

1. Update `kube_version` in group_vars
2. Run: `ansible-playbook -i inventory/mycluster/hosts.yaml kubespray/upgrade-cluster.yml`

## Monitoring and Maintenance

### Health Checks

- **Node Status**: All nodes in Ready state
- **Pod Status**: All system pods Running
- **Service Status**: All cluster services responsive
- **Certificate Status**: TLS certificates valid

### Backup Considerations

- **etcd Snapshots**: Regular backups of cluster state
- **Configuration Backup**: Version control inventory files
- **Certificate Backup**: TLS certificate backup strategy

## Troubleshooting

### Common Issues

- **Node Not Ready**: Check kubelet logs and network connectivity
- **Pod Scheduling**: Verify resource availability and node labels
- **Service Discovery**: Check CoreDNS configuration and network policies
- **Certificate Expiry**: Monitor and rotate certificates proactively

### Debug Commands

```bash
kubectl get nodes -o wide
kubectl describe node <node-name>
kubectl get pods -n kube-system
kubectl logs -n kube-system -l k8s-app=calico-node
```

## Quick Start Guide

### Using the Current Demo Setup ⚡

The demo is already running! Access the active services:

```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Access services (port-forwarding already active)
# Kibana: http://localhost:5602 (ELK Stack Dashboard)
# User Service: http://localhost:3001/health  
# Order Service: http://localhost:3002/health

# Generate sample logs for Kibana visualization
./scripts/generate-sample-logs.sh 50
```

### Deploying to Production Infrastructure

When ready to deploy the production 6-node cluster:

```bash
# 1. Provision infrastructure (6 Ubuntu servers)
# 2. Configure SSH access and update hosts.yaml IPs if needed
# 3. Deploy with Kubespray:

git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray  
pip install -r requirements.txt
ansible-playbook -i ../inventory/mycluster/hosts.yaml cluster.yml

# 4. Deploy the same applications to production cluster
kubectl apply -f k8s-manifests/
```

### Customizing the Configuration

To modify the production cluster configuration:

1. **Update Node IPs**: Edit `inventory/mycluster/hosts.yaml`
2. **Change Cluster Settings**: Modify `inventory/mycluster/group_vars/`
3. **Add/Remove Nodes**: Update the hosts.yaml children sections
4. **Network Configuration**: Adjust CIDR ranges in group_vars

This directory represents the **foundation layer** of the Kubernetes infrastructure, providing the blueprint for both development and production cluster topologies that enable all other project components to function effectively.
