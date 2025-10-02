# Data Layer

This folder contains all database and storage components that provide data persistence for the application.

## Components

### PostgreSQL Database (`postgres.yaml`)

- **Purpose**: Primary relational database for application data
- **Namespace**: `data-layer`
- **Port**: 5432
- **Features**:
  - Production-grade PostgreSQL configuration
  - Multiple database support (orders, users, analytics)
  - Enhanced query logging
  - Connection monitoring
  - Performance optimization

### Database Configuration (`postgres-configmap.yaml`)

- **Purpose**: PostgreSQL initialization and configuration
- **Contains**:
  - Database initialization scripts
  - Multiple database creation
  - User permissions setup
  - Logging configuration

### Persistent Storage (`postgres-pvc.yaml`)

- **Purpose**: Persistent volume claim for database storage
- **Storage**: 10Gi persistent volume
- **Access Mode**: ReadWriteOnce
- **Features**: Data persistence across pod restarts

## Deployment

```bash
# Deploy all data layer components
kubectl apply -f data-layer/

# Verify deployment
kubectl get pods -n data-layer
kubectl get pvc -n data-layer
```

## Access

```bash
# Port forward to PostgreSQL
kubectl port-forward svc/postgresql 5432:5432 -n data-layer

# Connect using psql
psql -h localhost -p 5432 -U postgres -d orders
psql -h localhost -p 5432 -U postgres -d users
psql -h localhost -p 5432 -U postgres -d analytics
```

## Database Schema

### Available Databases

- **orders**: Order management data
- **users**: User accounts and profiles  
- **analytics**: Business analytics and metrics

### Connection Details

- **Host**: `postgresql.data-layer.svc.cluster.local`
- **Port**: `5432`
- **Username**: `postgres`
- **Password**: Stored in Kubernetes secret

## Logging

PostgreSQL generates detailed logs including:

- **Query Logging**: All SQL queries with execution times
- **Connection Logging**: Client connections and disconnections
- **Error Logging**: Database errors and warnings
- **Performance Metrics**: Slow queries and connection statistics

Logs are sent to the `logs-data-layer-*` index in Elasticsearch.

## Configuration

- **Memory**: 512Mi limit for database operations
- **CPU**: 500m limit for query processing
- **Storage**: 10Gi persistent volume for data
- **Backup**: Persistent storage ensures data retention
- **Security**: Network policies restrict database access
- **Monitoring**: Health checks and performance logging enabled

## Security

- Database access restricted to `data-layer` namespace
- Service mesh policies control inter-service communication
- Secrets management for database credentials
- Network policies for traffic isolation