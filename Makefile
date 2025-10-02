.PHONY: setup deploy deploy-all validate remove clean logs kibana stop-kibana generate-logs cleanup-es update-logstash help

help:
	@echo "Kubespray + Ansible Demo with ELK Stack"
	@echo "=========================================="
	@echo "setup          - Create local Kubernetes cluster"
	@echo "deploy         - Deploy applications + ELK stack"
	@echo "deploy-all     - Deploy everything + generate sample logs"
	@echo "validate       - Validate cluster and apps"
	@echo "generate-logs  - Generate sample logs (50 entries)"
	@echo "cleanup-es     - Remove sample data, set 0 replicas"
	@echo "update-logstash- Update Logstash config from pipeline file"
	@echo "logs           - Open Kibana dashboard (kills existing port-forward)"
	@echo "kibana         - Port-forward to Kibana (background)"
	@echo "stop-kibana    - Stop Kibana port-forward"
	@echo "remove         - Remove applications + ELK stack"
	@echo "clean          - Delete cluster"

setup:
	./scripts/setup-simple.sh

deploy:
	ansible-playbook playbooks/main.yml -e action=deploy

deploy-all:
	@echo "Starting full deployment with sample logs..."
	@echo "============================================"
	./scripts/deploy.sh
	@echo ""
	@echo "Waiting for ELK stack to be fully ready..."
	@sleep 30
	@echo ""
	@echo "Generating sample logs..."
	./scripts/generate-sample-logs.sh 50
	@echo ""
	@echo "============================================"
	@echo "Deployment complete!"
	@echo "Access Kibana at: http://localhost:5601"
	@echo "To port-forward: make kibana"
	@echo ""

validate:
	ansible-playbook playbooks/main.yml -e action=validate

generate-logs:
	@echo "Generating 50 sample log entries..."
	./scripts/generate-sample-logs.sh 50
	@echo "Sample logs generated!"
	@echo "View them in Kibana: http://localhost:5601"

logs:
	@echo "Opening Kibana dashboard..."
	@echo "Checking for existing port-forward on port 5601..."
	@pkill -9 -f "kubectl port-forward.*5601" 2>/dev/null || true
	@sleep 2
	@echo "Kibana will be available at: http://localhost:5601"
	@echo "To create index patterns: kubespray-logs-* or kubernetes-logs-*"
	@echo "To stop: Ctrl+C"
	@echo ""
	kubectl port-forward -n monitoring svc/kibana 5601:5601

kibana:
	@echo "Starting Kibana port-forward in background..."
	@pkill -9 -f "kubectl port-forward.*5601" 2>/dev/null || true
	@sleep 2
	@echo "Access Kibana at: http://localhost:5601"
	@kubectl port-forward -n monitoring svc/kibana 5601:5601 > /dev/null 2>&1 &
	@echo "Kibana port-forward started in background"
	@echo "To stop: make stop-kibana"

stop-kibana:
	@echo "Stopping Kibana port-forward..."
	@pkill -9 -f "kubectl port-forward.*5601" 2>/dev/null || echo "No Kibana port-forward running"

cleanup-es:
	@echo "Cleaning up Elasticsearch and configuring 0 replicas..."
	./scripts/cleanup-elasticsearch.sh
	@echo ""
	@echo "Now generate logs with: make generate-logs"

update-logstash:
	@echo "Updating Logstash configuration from pipeline.conf file..."
	./scripts/apply-logstash-config.sh
	@echo "Step 2: Applying ConfigMap..."
	kubectl apply -f k8s-manifests/observability/logstash-configmap.yaml
	@echo ""
	@echo "Step 3: Restarting Logstash..."
	kubectl rollout restart deployment/logstash -n monitoring
	@echo ""
	@echo "✅ Logstash configuration updated!"
	@echo "Check status: kubectl get pods -n monitoring -l app=logstash"
	@echo "Check logs: kubectl logs -n monitoring deployment/logstash --tail=50"

remove:
	ansible-playbook playbooks/main.yml -e action=remove

clean:
	kind delete cluster --name kubespray-ansi-cluster