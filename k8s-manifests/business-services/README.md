# Business Services

This folder contains the application business logic services that handle core business functionality.

## Components

### Order Service (`order-service.yaml`)

- **Purpose**: Order management and processing service
- **Namespace**: `business-services`
- **Port**: 8080
- **Features**:
  - Order creation and tracking
  - Structured logging with request tracing
  - Business metrics collection
  - Integration with user service
  - Health checks and monitoring

### User Service (`user-service.yaml`)

- **Purpose**: User management and authentication service
- **Namespace**: `business-services`
- **Port**: 8081
- **Features**:
  - User registration and lookup
  - Inter-service communication with order service
  - Structured logging with user activity tracking
  - Database integration
  - Health checks and monitoring

## Deployment

```bash
# Deploy all business services
kubectl apply -f business-services/

# Verify deployment
kubectl get pods -n business-services
```

## Access

```bash
# Access Order Service
kubectl port-forward svc/order-service 8080:8080 -n business-services

# Access User Service
kubectl port-forward svc/user-service 8081:8081 -n business-services
```

## Testing

### Order Service Tests

```bash
# Health check
curl http://localhost:8080/health

# Create an order
curl -X POST http://localhost:8080/orders \
  -H 'Content-Type: application/json' \
  -d '{"item":"laptop","quantity":1,"customer":"john.doe"}'

# Get order status
curl http://localhost:8080/orders/{orderId}
```

### User Service Tests

```bash
# Health check
curl http://localhost:8081/health

# Create a user
curl -X POST http://localhost:8081/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"John Doe","email":"john@example.com"}'

# Get user details
curl http://localhost:8081/users/{userId}
```

## Logging

Both services generate structured logs with:

- **Request Tracing**: UUID-based request tracking
- **Business Metrics**: Order counts, user activities
- **Performance Metrics**: Response times, error rates
- **Service Communication**: Inter-service call logging
- **Health Monitoring**: Service availability and status

Logs are sent to the `logs-business-services-*` index in Elasticsearch.

## Configuration

- **Resource Limits**: Configured for production workloads
- **Environment Variables**: Service configuration and database connections
- **Health Probes**: Liveness and readiness checks enabled
- **Service Discovery**: Uses Kubernetes DNS for inter-service communication