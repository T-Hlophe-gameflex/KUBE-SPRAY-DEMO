# Scripts Directory

## Overview

The `scripts/` directory contains shell automation scripts that provide **local development infrastructure** and **cluster lifecycle management**. This directory serves as the **development environment layer**, enabling rapid setup, testing, and validation of Kubernetes environments for local development and testing purposes.

## Purpose

The scripts provide essential development operations:
- **Local Environment Setup**: Quick cluster creation for development
- **Development Workflow**: Streamlined local testing environment
- **Infrastructure Simulation**: Production-like local environments
- **Integration Testing**: End-to-end testing capabilities

## Architecture Philosophy

The scripts follow a **development-first approach**:

```
Developer Experience → Local Cluster → Application Testing → Production Readiness
```

This enables:
- **Rapid Iteration**: Quick setup and teardown cycles
- **Local Development**: Full-featured local Kubernetes environment
- **Testing Pipeline**: Validation before production deployment
- **Learning Environment**: Safe space for experimentation

## File Structure and Responsibilities

### setup-simple.sh - Local Cluster Bootstrap
**Purpose**: Creates a complete local Kubernetes development environment

**Infrastructure Created**:
- **kind Cluster**: Docker-based Kubernetes cluster
- **Network Configuration**: Proper port mappings for local access
- **Node Topology**: Multi-node setup mimicking production
- **Development Tools**: kubectl context and access configuration

**Cluster Specification**:
```yaml
Control Plane: 1 node (API server, scheduler, controller manager)
Worker Nodes: 2 nodes (application workloads)
Total Nodes: 3 (optimal for quorum testing)
```

**Key Features**:
- **Port Mapping**: Maps container ports to localhost for external access
- **Resource Allocation**: Optimized for local development resource constraints
- **Network Setup**: Configures Docker networking for cluster communication
- **Tool Integration**: Sets up kubectl context for immediate use

**Workflow Process**:
1. **Configuration Generation**: Creates kind cluster configuration
2. **Cluster Creation**: Deploys multi-node Kubernetes cluster
3. **Network Setup**: Configures networking and port mappings
4. **Validation**: Verifies cluster readiness and accessibility
5. **User Guidance**: Provides next steps for application deployment

## Technical Implementation

### kind Integration
**kind (Kubernetes in Docker)** provides:
- **Container-Based Nodes**: Each Kubernetes node runs as a Docker container
- **Real Kubernetes**: Full Kubernetes API and features
- **Local Networking**: Docker bridge networking for cluster communication
- **Resource Efficiency**: Minimal resource overhead for development

**Benefits for Development**:
- **Fast Setup**: Cluster ready in under 2 minutes
- **Isolation**: Complete isolation from host system
- **Reproducibility**: Consistent environment across development machines
- **Cost Efficiency**: No cloud resources required for development

### Network Architecture
**Local Development Networking**:
```
Host Machine (localhost)
├── Docker Bridge Network
│   ├── Control Plane Container (API Server)
│   ├── Worker Node 1 Container
│   └── Worker Node 2 Container
└── Port Mappings
    ├── 30080 → Frontend Service
    └── 30081 → API Service
```

**Port Strategy**:
- **NodePort Services**: Use consistent ports (30080, 30081) for predictable access
- **Host Mapping**: Map container ports to localhost for browser access
- **Service Discovery**: Internal DNS resolution within cluster

## Integration with Project Components

### With Applications Directory
- **Deployment Target**: Provides cluster for application deployment
- **Testing Environment**: Enables local testing of application manifests
- **Development Iteration**: Quick application update and testing cycles

### With Playbooks Directory
- **Automation Target**: Cluster serves as target for Ansible playbooks
- **Validation Environment**: Local validation before production deployment
- **Development Pipeline**: Enables complete development workflow locally

### With Inventory Directory
- **Local Simulation**: Simulates production inventory configuration locally
- **Testing Configuration**: Validates inventory settings in safe environment
- **Development Mapping**: Maps production concepts to local equivalents

## Development Workflow Integration

### Complete Development Cycle
```bash
1. make setup     # Create local cluster
2. make deploy    # Deploy applications
3. make validate  # Check health
4. # Development and testing
5. make remove    # Clean applications
6. make clean     # Remove cluster
```

### Rapid Iteration Cycle
```bash
# Make application changes
vim applications/02-api.yaml

# Redeploy quickly
make remove && make deploy

# Test changes
curl http://localhost:30080
```

### Testing and Validation
- **Unit Testing**: Individual component testing
- **Integration Testing**: Cross-component communication testing
- **End-to-End Testing**: Complete application workflow testing
- **Performance Testing**: Basic performance validation

## Docker and Container Integration

### Container Runtime
- **containerd**: Production-grade container runtime
- **Image Management**: Efficient image pulling and storage
- **Security**: Container isolation and security features
- **Monitoring**: Container metrics and logging

### Resource Management
**Development Resource Allocation**:
- **CPU**: Minimal CPU allocation for efficiency
- **Memory**: Optimized memory usage for local development
- **Storage**: Ephemeral storage for rapid testing
- **Network**: Efficient Docker networking

## Production Simulation

### Environment Parity
The local environment simulates production characteristics:
- **Multi-Node Topology**: Same node distribution as production
- **Network Policies**: Similar networking configuration
- **Service Discovery**: Identical DNS and service resolution
- **Security Model**: Same RBAC and security patterns

### Configuration Consistency
- **YAML Manifests**: Same application definitions used in production
- **Ansible Playbooks**: Same automation scripts for deployment
- **Network Configuration**: Consistent networking approach
- **Storage Patterns**: Similar storage abstraction patterns

## Performance Considerations

### Resource Optimization
**Local Development Tuning**:
- **Container Limits**: Appropriate resource limits for local machine
- **Image Strategy**: Efficient image pulling and caching
- **Network Optimization**: Minimal network overhead
- **Storage Strategy**: Optimized for development speed

### Scaling Simulation
- **Horizontal Scaling**: Test application scaling behavior
- **Load Distribution**: Validate load balancing across replicas
- **Resource Constraints**: Test behavior under resource pressure
- **Network Congestion**: Simulate network constraints

## Troubleshooting and Debugging

### Common Development Issues
- **Port Conflicts**: Resolve conflicts with other local services
- **Resource Exhaustion**: Handle local machine resource constraints
- **Network Issues**: Debug Docker networking problems
- **Image Problems**: Resolve container image pulling issues

### Debug Techniques
```bash
# Check cluster status
kubectl get nodes -o wide

# Inspect Docker containers
docker ps | grep kind

# Check port mappings
docker port kind-control-plane

# Network debugging
kubectl get services -o wide
```

### Performance Monitoring
```bash
# Resource usage
kubectl top nodes
kubectl top pods

# Cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

# Container logs
kubectl logs -f deployment/api-backend
```

## Security in Development

### Local Security Model
- **Network Isolation**: Docker network isolation
- **Container Security**: Standard container security practices
- **Access Control**: kubectl context-based access
- **Data Security**: Ephemeral data for development safety

### Development Best Practices
- **Clean Environments**: Regular cluster recreation for clean state
- **Credential Management**: Avoid production credentials in development
- **Network Security**: Use localhost-only access when possible
- **Data Isolation**: Keep development data separate from production

## CI/CD Integration

### Continuous Integration
```yaml
test-local:
  script:
    - ./scripts/setup-simple.sh
    - make deploy
    - make validate
    - # Run tests
    - make clean
```

### Development Pipeline
- **Pre-commit Hooks**: Validate configurations before commit
- **Branch Testing**: Test feature branches in isolated environments
- **Integration Testing**: Comprehensive testing before merge
- **Performance Baseline**: Establish performance benchmarks

## Best Practices

### Development Workflow
- **Regular Cleanup**: Clean environments prevent configuration drift
- **Version Control**: Track all configuration changes
- **Testing First**: Test locally before production deployment
- **Documentation**: Document development setup and procedures

### Resource Management
- **Efficient Usage**: Optimize for local machine resources
- **Clean Shutdown**: Proper cluster cleanup after development
- **Image Management**: Efficient container image usage
- **Network Cleanup**: Clean Docker networks after use

This directory represents the **development infrastructure layer** of the project, providing the essential foundation for local development, testing, and validation that enables rapid iteration and reliable delivery of Kubernetes applications.