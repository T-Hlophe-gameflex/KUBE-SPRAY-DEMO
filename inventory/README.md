# Inventory Directory

## Overview

The `inventory/` directory contains Kubernetes cluster infrastructure definitions and configuration management for Kubespray deployments. This directory serves as the **infrastructure configuration layer**, defining target nodes, cluster topology, and operational parameters for both local development and production environments.

## Purpose

The inventory system defines:
- **Target Infrastructure**: Which servers/nodes to use
- **Cluster Topology**: Control plane and worker node distribution
- **Network Configuration**: Pod and service CIDR ranges
- **Feature Sets**: Enabled Kubernetes features and add-ons
- **Security Settings**: Authentication and authorization configurations

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

**Structure**:
```yaml
all:
  hosts:                         # Individual node definitions
  children:
    kube_control_plane:         # Control plane nodes (masters)
    kube_node:                  # Worker nodes
    etcd:                       # etcd cluster nodes
```

**Key Features**:
- **High Availability**: Multiple control plane nodes for production
- **Quorum Management**: Odd number of etcd nodes (1, 3, 5)
- **Node Roles**: Separation of control plane and worker responsibilities
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

### Current Configuration
- **Pod CIDR**: 10.233.64.0/18 (16,384 pod IPs)
- **Service CIDR**: 10.233.0.0/18 (16,384 service IPs)
- **CNI Plugin**: Calico with BGP networking
- **DNS**: CoreDNS for service discovery

### Network Features
- **Network Policies**: Micro-segmentation support
- **Load Balancing**: IPVS-based kube-proxy
- **Ingress**: Optional nginx ingress controller
- **Service Mesh**: Ready for Istio integration

## Cluster Topology Design

### Development (Current)
```
1 Control Plane Node + 2 Worker Nodes = 3 Node Cluster
```
- **Pros**: Resource efficient, quick setup
- **Cons**: Single point of failure for control plane

### Production (Recommended)
```
3 Control Plane Nodes + 3+ Worker Nodes = 6+ Node Cluster
```
- **Pros**: High availability, fault tolerance
- **Cons**: Higher resource requirements

## Kubespray Integration

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

### With Applications Directory
- **Namespace**: Applications deployed to cluster defined here
- **DNS**: Service discovery uses cluster DNS configuration
- **Network**: Pod networking follows CIDR ranges defined here

### With Playbooks Directory
- **Target Cluster**: Ansible playbooks use this inventory
- **Context**: kubectl context points to cluster defined here
- **Validation**: Health checks verify inventory configuration

### With Scripts Directory
- **Setup Scripts**: Reference cluster configuration
- **Kind Integration**: Local development mirrors production topology
- **Validation**: Scripts verify inventory-defined cluster state

## Local Development vs Production

### Local (kind-based)
- **Purpose**: Development and testing
- **Nodes**: Simulated with Docker containers
- **Networking**: Docker bridge networks
- **Storage**: EmptyDir and HostPath volumes

### Production (Kubespray-based)
- **Purpose**: Production workloads
- **Nodes**: Physical/virtual machines
- **Networking**: Physical network infrastructure
- **Storage**: Network-attached storage, cloud volumes

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

This directory represents the **foundation layer** of the Kubernetes infrastructure, providing the blueprint for cluster topology and operational configuration that enables all other project components to function effectively.