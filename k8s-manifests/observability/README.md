# Observability Stack - ELK + Monitoring

## Overview

The observability layer provides comprehensive logging, monitoring, and visualization capabilities for the Kubernetes cluster using the **ELK Stack** (Elasticsearch, Logstash, Kibana) plus custom monitoring components.

**Current Status**: **Fully Operational** - All components running successfully with green cluster health.

## Components & Architecture

### Core ELK Stack

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Filebeat     │───▶│    Logstash     │───▶│ Elasticsearch   │
│ (Infrastructure)│    │  (Processing)   │    │   (Storage)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │     Kibana      │
                                               │ (Visualization) │
                                               └─────────────────┘
```

#### Elasticsearch (`elasticsearch.yaml` + `elasticsearch-configmap.yaml` + `elasticsearch-pvc.yaml`)
- **Purpose**: Centralized log storage and search engine
- **Configuration**: Single-node cluster optimized for demo environments
- **Storage**: 10Gi persistent volume for data retention
- **Network**: 9200 (HTTP API), 9300 (transport)
- **Status**: Green cluster health with fixed disk threshold settings

**Key Settings**:
```yaml
Heap Size: 512MB (optimized for local development)
Cluster: kubespray-elk-cluster (single-node discovery)
Security: Disabled for demo simplicity
Monitoring: Built-in X-Pack monitoring enabled
```

#### Logstash (`logstash.yaml` + `logstash-configmap.yaml`)
- **Purpose**: Log processing pipeline with Kubernetes metadata enrichment
- **Input**: Beats protocol on port 5044 (from Filebeat)
- **Processing**: JSON parsing, Kubernetes metadata addition, service classification
- **Output**: Elasticsearch with daily indices (`kubespray-logs-YYYY.MM.dd`)
- **Status**: Main pipeline running successfully

**Processing Pipeline**:
```text
Raw Logs → JSON Parse → K8s Metadata → Service Classification → Index Routing → Elasticsearch
```

#### Kibana (`kibana.yaml`)
- **Purpose**: Log visualization and dashboard interface
- **Access**: http://localhost:5602 (via port-forwarding)
- **Features**: 
  - Index pattern: `kubespray-logs-*` with `@timestamp` time field
  - Real-time log exploration and visualization
  - Dashboard creation for service metrics
- **Status**: Connected to Elasticsearch with sample data

### Monitoring Components

#### Custom Monitoring Dashboard (`monitoring-dashboard.yaml`)
- **Purpose**: Cluster health and service status monitoring
- **Port**: 3000 (HTTP API)
- **Features**:
  - Cluster health checks
  - Service dependency monitoring
  - Custom metrics collection
- **Status**: Running and responsive

## Quick Start

### Access Services

```bash
# Kibana Dashboard (Primary Interface)
kubectl port-forward -n observability svc/kibana 5602:5601
# Open: http://localhost:5602

# Elasticsearch API (for debugging)
kubectl port-forward -n observability svc/elasticsearch 9200:9200
# Test: curl http://localhost:9200/_cluster/health

# Monitoring Dashboard
kubectl port-forward -n observability svc/monitoring-dashboard 3000:3000
# Test: curl http://localhost:3000/health
```

### Generate Sample Data

```bash
# From project root directory
./scripts/generate-sample-logs.sh 50

# Check data ingestion
kubectl exec -n observability deployment/elasticsearch -- \
  curl -s "http://localhost:9200/kubespray-logs-*/_count"
```

### Verify Stack Health

```bash
# Check all observability pods
kubectl get pods -n observability

# Expected output:
# elasticsearch-xxx          1/1     Running
# kibana-xxx                 1/1     Running  
# logstash-xxx               1/1     Running
# monitoring-dashboard-xxx   1/1     Running
```

## Data Visualization in Kibana

### Setting Up Index Patterns

1. **Access Kibana**: http://localhost:5602
2. **Navigate**: Menu → Stack Management → Index Patterns
3. **Create Pattern**: 
   - Pattern: `kubespray-logs-*`
   - Time field: `@timestamp`
4. **Explore Data**: Menu → Discover

### Available Log Fields

**Service Information**:
- `service` - Service name (user-service, order-service, etc.)
- `k8s_namespace` - Kubernetes namespace
- `k8s_pod` - Pod name
- `service_group` - Functional grouping

**Log Content**:
- `level` - Log level (INFO, WARN, ERROR, DEBUG)
- `message` - Log message content
- `@timestamp` - Event timestamp

**Performance Metrics**:
- `response_time` - API response time in milliseconds
- `amount` - Transaction amounts (for business services)
- `request_id` - Request tracing identifier

### Recommended Visualizations

#### 1. Service Performance Dashboard
```text
┌─ Response Time Trends (Line Chart) ─┐
│ Y-axis: Average response_time        │
│ X-axis: @timestamp (time histogram) │
│ Series: service.keyword              │
└─────────────────────────────────────┘

┌─ Log Level Distribution (Pie Chart) ─┐
│ Size: Count                          │
│ Slices: level.keyword                │
└─────────────────────────────────────┘
```

#### 2. Environment Monitoring
```text
┌─ Service Activity (Vertical Bar) ────┐
│ Y-axis: Count                        │
│ X-axis: service.keyword              │
│ Split: k8s_namespace.keyword         │
└─────────────────────────────────────┘

┌─ Error Rate Tracking (Area Chart) ───┐
│ Filter: level:ERROR OR level:WARN    │
│ Y-axis: Count                        │
│ X-axis: @timestamp                   │
└─────────────────────────────────────┘
```

### Search Queries (KQL Examples)

```bash
# Find errors in production
level: ERROR AND k8s_namespace: prod

# Find slow requests (>100ms)
response_time > 100

# Find specific service logs
service: "user-service" AND @timestamp >= now-1h

# Find high-value transactions
amount > 500 AND service: "order-service"
```

## Configuration Details

### Log Processing Pipeline

**Logstash Configuration** (`logstash-configmap.yaml`):
```yaml
Input: Beats on port 5044
Filter: 
  - JSON parsing for structured logs
  - Kubernetes metadata enrichment
  - Service group classification
  - Timestamp normalization
Output: 
  - Elasticsearch with daily indices
  - Console output for debugging
```

**Service Classification Logic**:
- `observability` namespace → "observability" group
- `business-services` namespace → "business-services" group
- `data-layer` namespace → "data-layer" group
- `prod/staging/dev` namespaces → "environments" group
- Others → "system" group

### Data Retention

**Index Management**:
- **Pattern**: `kubespray-logs-YYYY.MM.dd`
- **Retention**: Manual cleanup (no automatic deletion configured)
- **Storage**: Persistent volume ensures data survives pod restarts

### Resource Allocation

**Elasticsearch**:
- Heap: 512MB (down from 2GB for demo efficiency)
- Memory Request: 1Gi
- CPU Request: 500m
- Storage: 10Gi persistent volume

**Logstash**:
- Heap: 2GB
- Memory Request: 2Gi  
- CPU Request: 500m

**Kibana**:
- Memory Request: 1Gi
- CPU Request: 500m

## Integration with Project Components

### Log Sources

**Business Services** (`business-services` namespace):
- User Service API logs
- Order Service API logs
- Service-to-service communication logs
- Database connection logs

**Data Layer** (`data-layer` namespace):
- PostgreSQL database logs
- Connection pool metrics
- Query performance logs

**Infrastructure** (`infrastructure` namespace):
- Filebeat agent logs from all nodes
- System component logs
- Network and storage logs

**Multi-Environment Logs**:
- Production environment (`prod` namespace)
- Staging environment (`staging` namespace)  
- Development environment (`dev` namespace)

### Service Mesh Integration

**Log Flow Architecture**:
```text
Application Pods → Container Logs → Filebeat → Logstash → Elasticsearch → Kibana
     ↓              ↓                  ↓           ↓            ↓           ↓
   Services     Log Files         Log Shipping  Processing   Storage  Visualization
```

## Troubleshooting

### Common Issues & Solutions

#### Elasticsearch Yellow/Red Status
```bash
# Check cluster health
kubectl exec -n observability deployment/elasticsearch -- \
  curl -s "http://localhost:9200/_cluster/health?pretty"

# Fix: Set replicas to 0 for single-node cluster
kubectl exec -n observability deployment/elasticsearch -- \
  curl -X PUT "http://localhost:9200/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index": {"number_of_replicas": 0}}'
```

#### Logstash Not Processing Logs
```bash
# Check Logstash pipeline status
kubectl logs -n observability deployment/logstash | grep "Pipeline started"

# Verify Beats input listening
kubectl logs -n observability deployment/logstash | grep "Starting input listener"
```

#### Kibana Connection Issues
```bash
# Check Kibana connectivity to Elasticsearch
kubectl logs -n observability deployment/kibana | grep -i "elasticsearch"

# Verify service resolution
kubectl exec -n observability deployment/kibana -- \
  nslookup elasticsearch.observability.svc.cluster.local
```

#### No Data in Kibana
```bash
# Check if indices exist
kubectl exec -n observability deployment/elasticsearch -- \
  curl -s "http://localhost:9200/_cat/indices?v"

# Generate test data
./scripts/generate-sample-logs.sh 20

# Check Filebeat is sending data (if deployed)
kubectl logs -n infrastructure daemonset/filebeat
```

### Debug Commands

```bash
# Full observability stack status
kubectl get all -n observability

# Check persistent storage
kubectl get pvc -n observability

# Elasticsearch cluster info
kubectl exec -n observability deployment/elasticsearch -- \
  curl -s "http://localhost:9200/"

# View recent Logstash processing
kubectl logs -n observability deployment/logstash --tail=50

# Monitor Kibana startup
kubectl logs -n observability deployment/kibana --follow
```

## 📈 Performance & Scaling

### Current Limits (Demo Environment)

- **Elasticsearch**: Single-node, 512MB heap, 10Gi storage
- **Logstash**: Single instance, 2GB heap
- **Kibana**: Single instance, 1GB memory
- **Throughput**: ~1000 logs/minute (demo workload)

### Production Scaling Considerations

**Elasticsearch Cluster**:
- 3+ nodes for high availability
- Dedicated master, data, and ingest nodes
- Increased heap size (recommendation: 50% of available RAM)
- SSD storage for better I/O performance

**Logstash Pipeline**:
- Multiple Logstash instances for horizontal scaling
- Persistent queues for reliability
- Output batching optimization

**Data Retention**:
- Index lifecycle management (ILM)
- Automatic archival and deletion policies
- Cold/warm tier storage architecture

## 🔐 Security Considerations

**Current Configuration** (Demo):
- X-Pack security disabled for simplicity
- No authentication required
- Internal cluster communication only

**Production Recommendations**:
- Enable X-Pack security with TLS
- Configure authentication (LDAP/SAML)
- Implement role-based access control (RBAC)
- Network policies for traffic isolation
- Audit logging for compliance

## File Inventory

```text
observability/
├── README.md                    # This comprehensive guide
├── elasticsearch.yaml           # Elasticsearch deployment & service
├── elasticsearch-configmap.yaml # Elasticsearch configuration
├── elasticsearch-pvc.yaml       # Persistent storage claim
├── logstash.yaml               # Logstash deployment & service  
├── logstash-configmap.yaml     # Logstash pipeline configuration
├── kibana.yaml                 # Kibana deployment & service
└── monitoring-dashboard.yaml   # Custom monitoring service
```

**All files are actively used** - No unused configurations detected.

---

This observability stack provides **production-ready logging and monitoring** capabilities while remaining **resource-efficient** for demonstration and development environments. The ELK stack integration with Kubernetes-native log collection creates a comprehensive observability solution for modern microservices architectures.