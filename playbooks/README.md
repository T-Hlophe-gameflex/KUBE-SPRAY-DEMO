# Playbooks Directory

## Overview

The `playbooks/` directory contains Ansible automation scripts that manage the complete application lifecycle on Kubernetes clusters. This directory serves as the **automation and orchestration layer**, providing consistent, repeatable operations for deploying, managing, and maintaining applications across different environments.

## Purpose

The playbooks provide automated operations for:

- **Application Deployment**: Automated rollout of multi-tier applications
- **Lifecycle Management**: Deploy, update, scale, and remove operations
- **Health Validation**: Cluster and application health monitoring
- **Environment Consistency**: Same operations across dev/staging/production

## Architecture Pattern

The playbooks follow a **modular task-based architecture**:

```
main.yml (Orchestrator)
├── deploy-apps.yml (Application Deployment)
├── remove-apps.yml (Application Cleanup)
└── validate-cluster.yml (Health Monitoring)
```

This design enables:

- **Single Entry Point**: One command interface for all operations
- **Modular Tasks**: Reusable components for different scenarios
- **Action-Based Control**: Dynamic behavior based on input parameters

## File Structure and Responsibilities

### main.yml - Central Orchestrator

**Purpose**: Main entry point that routes actions to appropriate task modules

**Key Features**:

- **Action Routing**: Dispatches to correct playbook based on `action` parameter
- **Parameter Validation**: Ensures required inputs are provided
- **Local Execution**: Runs on localhost using local kubectl context
- **Error Handling**: Graceful failure handling and user feedback

**Usage Pattern**:

```bash
ansible-playbook playbooks/main.yml -e action=<deploy|remove|validate>
```

**Workflow Logic**:

1. Display requested action for user confirmation
2. Route to appropriate task module based on action parameter
3. Execute specialized tasks for the requested operation
4. Provide feedback on operation results

### deploy-apps.yml - Application Deployment

**Purpose**: Automated deployment of the complete application stack

**Deployment Sequence**:

1. **Database Layer**: Deploy PostgreSQL with persistent storage
2. **API Layer**: Deploy Node.js backend with database connectivity
3. **Frontend Layer**: Deploy React/nginx frontend with API integration
4. **Validation**: Wait for all deployments to become ready
5. **Status Report**: Display deployment results and access information

**Key Features**:

- **Sequential Deployment**: Ensures proper dependency order
- **Readiness Checks**: Waits for each component to be fully operational
- **Error Recovery**: Handles partial deployment failures gracefully
- **Status Reporting**: Provides clear feedback on deployment progress

**Integration Points**:

- Uses manifest files from `applications/` directory
- Applies configurations to cluster defined in `inventory/`
- Validates deployment using same checks as validate playbook

### remove-apps.yml - Application Cleanup

**Purpose**: Clean removal of all application components

**Removal Process**:

1. **Graceful Shutdown**: Stops all application pods safely
2. **Service Cleanup**: Removes all services and endpoints
3. **Configuration Cleanup**: Removes ConfigMaps and secrets
4. **Storage Cleanup**: Removes persistent volume claims
5. **Verification**: Confirms complete removal of resources

**Key Features**:

- **Complete Cleanup**: Removes all application-related resources
- **Error Tolerance**: Continues cleanup even if some resources are missing
- **Verification**: Confirms successful removal
- **Data Safety**: Preserves cluster infrastructure while removing workloads

### validate-cluster.yml - Health Monitoring

**Purpose**: Comprehensive health validation of cluster and applications

**Validation Scope**:

1. **Cluster Connectivity**: API server accessibility and authentication
2. **Node Health**: All cluster nodes in ready state
3. **Application Status**: Running pods and service availability
4. **Resource Usage**: Basic resource consumption monitoring
5. **Networking**: Service discovery and connectivity validation

**Health Checks**:

- **Infrastructure**: Cluster API, nodes, and system components
- **Applications**: Pod status, service endpoints, and resource health
- **Connectivity**: Internal service communication and external access
- **Performance**: Basic performance indicators and resource utilization

## Ansible Integration Patterns

### Execution Model

- **Local Execution**: All playbooks run on localhost
- **kubectl Integration**: Uses kubectl commands for Kubernetes operations
- **Context Awareness**: Operates on current kubectl context
- **Idempotent Operations**: Safe to run multiple times

### Variable Management

- **Action Parameters**: Runtime behavior control via `-e action=<value>`
- **Path Resolution**: Relative paths for portability
- **Environment Detection**: Automatic cluster context detection
- **Configuration Inheritance**: Uses global ansible.cfg settings

### Error Handling Strategy

- **Graceful Degradation**: Continues operations when possible
- **User Feedback**: Clear error messages and troubleshooting guidance
- **Rollback Capability**: Can reverse operations if needed
- **Logging Integration**: Detailed operation logging for debugging

## Integration with Project Components

### With Applications Directory

- **Manifest Consumption**: Applies YAML manifests to cluster
- **Configuration Management**: Handles ConfigMaps and secrets
- **Resource Lifecycle**: Manages complete application resource lifecycle

### With Inventory Directory

- **Target Cluster**: Operates on cluster defined in inventory
- **Context Usage**: Uses kubectl context for cluster communication
- **Environment Awareness**: Adapts to different cluster configurations

### With Scripts Directory

- **Workflow Integration**: Can be called from setup scripts
- **Validation Chains**: Used by validation scripts for health checks
- **Automation Pipeline**: Part of complete deployment automation

## Operational Workflows

### Development Workflow

1. **Setup**: `./scripts/setup-simple.sh` (creates cluster)
2. **Deploy**: `make deploy` (deploys applications)
3. **Validate**: `make validate` (checks health)
4. **Iterate**: Modify applications and redeploy
5. **Cleanup**: `make remove` (removes applications)

### Production Workflow

1. **Infrastructure**: Deploy cluster via Kubespray
2. **Validation**: Validate cluster readiness
3. **Application**: Deploy applications via playbooks
4. **Monitoring**: Continuous health validation
5. **Updates**: Rolling updates via playbook re-execution

### CI/CD Integration

```yaml
stages:
  - validate-cluster
  - deploy-applications
  - run-tests
  - promote-to-production
```

## Advanced Features

### Parallel Execution

- Multiple application components deployed concurrently where possible
- Dependency management ensures proper sequencing
- Resource optimization through intelligent scheduling

### Environment Management

- **Development**: Local kind clusters
- **Staging**: Multi-node test clusters
- **Production**: Full Kubespray-managed clusters

### Monitoring Integration

- Health check results can be exported to monitoring systems
- Application metrics collection during deployment
- Performance baseline establishment

## Security Considerations

### Access Control

- **RBAC**: Respects Kubernetes role-based access control
- **Context Isolation**: Uses dedicated kubectl contexts per environment
- **Credential Management**: Leverages Kubernetes service accounts

### Network Security

- **Internal Communication**: Validates secure service-to-service communication
- **External Access**: Manages external exposure points securely
- **Network Policies**: Can deploy network segmentation rules

## Troubleshooting and Debugging

### Common Issues

- **kubectl Context**: Ensure correct cluster context is active
- **Resource Conflicts**: Handle existing resources gracefully
- **Network Issues**: Validate cluster networking configuration
- **Permission Errors**: Verify RBAC permissions for operations

### Debug Techniques

```bash
# Verbose execution
ansible-playbook playbooks/main.yml -e action=validate -vvv

# Check cluster context
kubectl config current-context

# Validate connectivity
kubectl cluster-info

# Resource inspection
kubectl get all --all-namespaces
```

### Logging and Monitoring

- **Ansible Logs**: Detailed execution logs in ansible.log
- **Kubernetes Events**: Monitor cluster events for deployment issues
- **Application Logs**: Pod-level logging for application troubleshooting

## Best Practices

### Playbook Development

- **Idempotent Design**: Operations safe to repeat
- **Error Handling**: Comprehensive error catching and user guidance
- **Documentation**: Clear task names and descriptions
- **Testing**: Validate playbooks in multiple environments

### Production Deployment

- **Staging Validation**: Test all playbooks in staging environment
- **Backup Strategy**: Ensure data backup before destructive operations
- **Rollback Planning**: Maintain ability to revert deployments
- **Change Management**: Version control for all playbook modifications

This directory represents the **operational automation layer** of the project, providing reliable, consistent, and repeatable operations that bridge the gap between infrastructure (inventory) and applications, enabling professional-grade deployment and management capabilities.
