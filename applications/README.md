# Applications Directory

## Overview

The `applications/` directory contains Kubernetes manifest files that define the multi-tier application stack deployed to the cluster. This directory represents the **workload layer** of the project, containing declarative configurations for a complete web application ecosystem.

## Architecture

The application stack follows a **3-tier architecture pattern**:

```
Frontend (nginx) → API (Node.js) → Database (PostgreSQL)
```

### Data Flow
1. **User Request** → Frontend (Port 30080)
2. **Frontend** → API Service (Internal: Port 3000)
3. **API** → PostgreSQL Service (Internal: Port 5432)
4. **Response** ← Reverse path back to user

## File Structure

### 01-database.yaml
**Purpose**: PostgreSQL database layer with persistent storage
**Components**:
- **ConfigMap**: Database credentials and configuration
- **PersistentVolumeClaim**: 1GB storage for database data
- **Deployment**: Single PostgreSQL instance
- **Service**: Internal cluster service (ClusterIP)

**Key Features**:
- Persistent data storage survives pod restarts
- Environment-based configuration
- Internal-only access (no external exposure)

### 02-api.yaml
**Purpose**: Node.js REST API backend service
**Components**:
- **ConfigMap**: API configuration and database connection strings
- **Deployment**: 2 replicas for high availability
- **Service**: Internal API service (ClusterIP)

**Key Features**:
- Horizontal scaling (2 replicas)
- Database connectivity via service discovery
- Health check endpoint (/health)
- CORS enabled for frontend communication

### 03-frontend-simple.yaml
**Purpose**: React frontend with nginx web server
**Components**:
- **ConfigMap**: HTML/CSS/JavaScript application code
- **Deployment**: 2 replicas for load distribution
- **Service**: External access via NodePort (30080)

**Key Features**:
- Static file serving via nginx
- External accessibility
- Load balanced across replicas
- Responsive web interface

## Service Discovery

The applications use **Kubernetes DNS-based service discovery**:

- Frontend calls API via: `http://api-service:3000`
- API calls database via: `postgresql://demouser:demopass123@postgres-service:5432/demoapp`

## Networking

### Internal Communication
- **API ↔ Database**: ClusterIP services (internal only)
- **Frontend ↔ API**: ClusterIP service (internal only)

### External Access
- **User ↔ Frontend**: NodePort service (port 30080)

## Resource Requirements

### Minimal Resource Allocation
- **Database**: 1 pod, 1GB persistent storage
- **API**: 2 pods for availability
- **Frontend**: 2 pods for load distribution

### Scaling Considerations
- API tier can be scaled horizontally by increasing replicas
- Database uses single instance (suitable for demo)
- Frontend serves static content, easily scalable

## Integration with Project Components

### With Playbooks Directory
- Deployed via `ansible-playbook playbooks/main.yml -e action=deploy`
- Managed through Ansible automation
- Supports lifecycle operations (deploy/remove/validate)

### With Inventory Directory
- Target cluster defined in inventory configuration
- Namespace and cluster context from inventory settings

### With Scripts Directory
- Can be deployed after cluster setup via `setup-simple.sh`
- Validated through automated health checks

## Configuration Management

### Environment Variables
- Database credentials stored in ConfigMaps
- API configuration externalized
- Frontend configuration embedded in HTML

### Security Considerations
- Credentials in ConfigMaps (demo purposes)
- Internal service communication only
- No TLS termination (local development)

## Development Workflow

1. **Modify** application manifests as needed
2. **Apply** changes via Ansible playbooks
3. **Validate** deployment through health checks
4. **Scale** by adjusting replica counts
5. **Update** by modifying ConfigMaps and redeploying

## Production Considerations

For production deployment, consider:
- **Secrets** instead of ConfigMaps for credentials
- **Resource limits** and requests for each container
- **Health checks** (liveness/readiness probes)
- **TLS/SSL** termination
- **Ingress controllers** instead of NodePort
- **StatefulSets** for database with proper backup strategies
- **Monitoring** and logging integration

## Troubleshooting

### Common Issues
- **Pod startup failures**: Check resource availability
- **Service connectivity**: Verify service discovery DNS
- **Data persistence**: Ensure PVC is bound correctly
- **External access**: Confirm NodePort service configuration

### Debug Commands
```bash
kubectl get pods,services -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl port-forward service/frontend-service 8080:80
```

This directory represents the **business logic layer** of the Kubernetes application, containing all workload definitions required for a functional multi-tier web application.