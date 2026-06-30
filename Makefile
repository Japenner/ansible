.DEFAULT_GOAL := help
PLAYBOOK := ubuntu.yml

.PHONY: help install run check lint test docker clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-9s\033[0m %s\n", $$1, $$2}'

install: ## Install Ansible via the official PPA (Ubuntu)
	sudo apt-add-repository -y ppa:ansible/ansible
	sudo apt-get update -y
	sudo apt-get install -y ansible

run: ## Provision this machine (prompts for vault + sudo passwords)
	ansible-playbook --ask-vault-pass --ask-become-pass $(PLAYBOOK)

check: ## Syntax-check the playbook
	ansible-playbook --syntax-check $(PLAYBOOK)

lint: ## Run ansible-lint and yamllint (must be installed)
	ansible-lint
	yamllint .

docker: ## Build the Docker test images
	./build-dockers

test: docker ## Build the test image, then syntax-check inside it
	docker run --rm new-computer ansible-playbook --syntax-check ubuntu.yml

clean: ## Remove installed packages and configs
	./clean-env
