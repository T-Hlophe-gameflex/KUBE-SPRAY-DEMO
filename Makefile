.PHONY: setup deploy validate remove clean help

help:
	@echo "Kubespray + Ansible Demo"
	@echo "======================="
	@echo "setup     - Create local Kubernetes cluster"
	@echo "deploy    - Deploy applications"
	@echo "validate  - Validate cluster and apps"
	@echo "remove    - Remove applications"
	@echo "clean     - Delete cluster"

setup:
	./scripts/setup-simple.sh

deploy:
	ansible-playbook playbooks/main.yml -e action=deploy

validate:
	ansible-playbook playbooks/main.yml -e action=validate

remove:
	ansible-playbook playbooks/main.yml -e action=remove

clean:
	kind delete cluster --name kubespray-ansi-cluster