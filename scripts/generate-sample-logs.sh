#!/bin/bash

# Generate sample logs for Kibana visualization
# Usage: ./generate-sample-logs.sh [number_of_entries]

ENTRIES=${1:-20}
SERVICES=("user-service" "order-service" "payment-service" "notification-service")
LEVELS=("INFO" "WARN" "ERROR" "DEBUG")
NAMESPACES=("backend" "monitoring" "database" "system")

echo "Generating $ENTRIES sample log entries..."

for i in $(seq 1 $ENTRIES); do
    SERVICE=${SERVICES[$((RANDOM % ${#SERVICES[@]}))]}
    LEVEL=${LEVELS[$((RANDOM % ${#LEVELS[@]}))]}
    NAMESPACE=${NAMESPACES[$((RANDOM % ${#NAMESPACES[@]}))]}
    RESPONSE_TIME=$((RANDOM % 500 + 10))
    AMOUNT=$((RANDOM % 2000 + 10))
    
    # Generate realistic messages based on service
    case $SERVICE in
        "user-service")
            MESSAGES=("User login successful" "User profile updated" "Password reset requested" "User session expired")
            ;;
        "order-service")
            MESSAGES=("Order created successfully" "Order payment processed" "Order shipped" "Order cancelled")
            ;;
        "payment-service")
            MESSAGES=("Payment authorized" "Payment declined" "Refund processed" "Payment timeout")
            ;;
        "notification-service")
            MESSAGES=("Email sent" "SMS delivered" "Push notification sent" "Notification failed")
            ;;
    esac
    
    MESSAGE=${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}
    
    # Write to both indices: kubespray-logs (consolidated) and kubernetes-logs (namespace-specific)
    kubectl exec -n monitoring deployment/logstash -- curl -X POST \
        "http://elasticsearch.monitoring.svc.cluster.local:9200/kubespray-logs-$(date +%Y.%m.%d)/_doc" \
        -H 'Content-Type: application/json' \
        -d "{
            \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\",
            \"service\": \"$SERVICE\",
            \"level\": \"$LEVEL\",
            \"message\": \"$MESSAGE\",
            \"k8s_namespace\": \"$NAMESPACE\",
            \"k8s_pod\": \"$SERVICE-$(openssl rand -hex 4)-$(openssl rand -hex 4)\",
            \"service_group\": \"$NAMESPACE\",
            \"request_id\": \"req-$(openssl rand -hex 6)\",
            \"user_id\": \"user-$((RANDOM % 1000))\",
            \"response_time\": $RESPONSE_TIME,
            \"amount\": $AMOUNT,
            \"environment\": \"$NAMESPACE\"
        }" -s -o /dev/null
    
    if [ $((i % 10)) -eq 0 ]; then
        echo "Generated $i/$ENTRIES entries..."
    fi
    
    # Small delay to spread timestamps
    sleep 0.1
done

echo ""
echo "Generated $ENTRIES sample log entries!"
echo ""
echo "View in Kibana: http://localhost:5601"
echo "Index patterns available:"
echo "  - kubespray-logs-* (consolidated view of all logs)"
echo "  - kubernetes-logs-* (namespace-specific logs)"
echo ""
echo "Access Kibana: make logs"
