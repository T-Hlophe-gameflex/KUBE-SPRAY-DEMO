# Kubespray + Ansible Kubernetes Demo

Production-ready Kubernetes cluster deployment using Kubespray and Ansible with multi-tier application demo.

## Features

- 3-node cluster with proper quorum balance (1 control-plane + 2 workers)
- Multi-tier application stack (PostgreSQL + Node.js API + React frontend)
- Complete Ansible automation for deployment lifecycle
- Local development setup with kind

## Quick Start

### Local Development

1. **Setup cluster**
   ```bash
   ./scripts/setup-simple.sh
   ```

2. **Deploy applications**
   ```bash
   ansible-playbook playbooks/main.yml -e action=deploy
   ```

3. **Access application**
   - Web: http://localhost:30080
   - API: http://localhost:30081/health

### Manage Applications

```bash
# Deploy
ansible-playbook playbooks/main.yml -e action=deploy

# Validate
ansible-playbook playbooks/main.yml -e action=validate

# Remove
ansible-playbook playbooks/main.yml -e action=remove
```

## Production Deployment

For production use with real infrastructure:

```bash
# Configure your inventory
cp inventory/mycluster/hosts.yaml.example inventory/mycluster/hosts.yaml
# Edit with your server IPs

# Deploy cluster
ansible-playbook -i inventory/mycluster/hosts.yaml kubespray/cluster.yml
```

## Prerequisites

- Docker and kind for local development
- kubectl
- Ansible 2.12+
- Python 3.8+

## Repository Structure

```
├── applications/            # Kubernetes manifests and multi-tier app
├── inventory/mycluster/    # Kubespray cluster configuration  
├── playbooks/              # Ansible automation and lifecycle
├── scripts/                # Local development and setup
└── Makefile                # Simplified command interface
```

## Documentation

Each directory contains comprehensive documentation explaining its purpose and integration:

- **[applications/README.md](applications/README.md)** - Multi-tier application architecture, Kubernetes manifests, and service discovery
- **[inventory/README.md](inventory/README.md)** - Kubespray integration, cluster topology, and network configuration
- **[playbooks/README.md](playbooks/README.md)** - Ansible automation patterns, lifecycle management, and operational workflows
- **[scripts/README.md](scripts/README.md)** - Local development infrastructure, cluster lifecycle, and testing environment

## Requirements

Install dependencies:

```bash
pip install -r requirements.txt
ansible-galaxy collection install kubernetes.core
```