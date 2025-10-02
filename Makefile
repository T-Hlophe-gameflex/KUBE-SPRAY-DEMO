.PHONY: setup deploy validate remove clean logs kibana help

help:
	@echo "Kubespray + Ansible Demo with ELK Stack"
	@echo "======================================="
	@echo "setup     - Create local Kubernetes cluster"
	@echo "deploy    - Deploy applications + ELK stack"
	@echo "validate  - Validate cluster and apps"
	@echo "logs      - Open Kibana dashboard"
	@echo "kibana    - Port-forward to Kibana (background)"
	@echo "remove    - Remove applications + ELK stack"
	@echo "clean     - Delete cluster"

setup:
	./scripts/setup-simple.sh

deploy:
	ansible-playbook playbooks/main.yml -e action=deploy

validate:
	ansible-playbook playbooks/main.yml -e action=validate

logs:
	@echo "Opening Kibana dashboard..."
	@echo "Kibana will be available at: http://localhost:5601"
	@echo "To create index pattern: kubespray-logs-*"
	@echo "To stop: Ctrl+C"
	kubectl port-forward svc/kibana 5601:5601

kibana:
	@echo "Starting Kibana port-forward in background..."
	@echo "Access Kibana at: http://localhost:5601"
	kubectl port-forward svc/kibana 5601:5601 > /dev/null 2>&1 &
	@echo "Kibana port-forward started (PID: $$!)"

remove:
	ansible-playbook playbooks/main.yml -e action=remove

clean:
	kind delete cluster --name kubespray-ansi-cluster