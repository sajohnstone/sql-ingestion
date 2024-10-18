.PHONY: plan apply destroy documentation check-security shell format lint format prep help set-env setup run

ENV=dev
SUBFOLDER=.
VARS="./$(ENV).tfvars"
CURRENT_FOLDER=$(shell basename "$$(pwd)")
WORKSPACE="$(ENV)"
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

# Python variables
VENV_DIR = venv
PYTHON = python3
PIP = $(VENV_DIR)/bin/pip
SCRIPT = ./data/import.py

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(ENV) ]; then \
		echo "$(BOLD)$(RED)ENV was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`AWS_PROFILE=whatever ENV=demo REGION=us-east-2 make plan\`$(RESET)"; \
		exit 1; \
	 fi
	@if [ ! -f "$(VARS)" ]; then \
		echo "$(BOLD)$(RED)Could not find variables file: $(VARS)$(RESET)"; \
		exit 1; \
	 fi

prep: set-env
	@docker-compose run --rm build terraform init
	@echo "$(BOLD)Switching to workspace $(WORKSPACE)$(RESET)"
	@docker-compose run --rm build terraform workspace select $(WORKSPACE)

format: prep ## Rewrites all Terraform configuration files to a canonical format.
	@docker-compose run --rm build terraform fmt -write=true -recursive

lint: prep ## Check for possible errors best practices
	@docker-compose run --rm build tflint

shell: ## Grants shell access to the Docker image for debugging
	@docker-compose run --rm build /bin/bash

check-security: prep ## Static analysis of your terraform templates to spot potential security issues.
	@docker-compose run --rm build tfsec .

documentation: prep ## Generate README.md 
	@docker-compose run --rm build terraform-docs markdown table --output-file README.md --output-mode inject . 

plan: prep ## Show deployment plan
	@docker-compose run --rm build terraform plan -var-file="$(VARS)" 

apply: prep ## Deploy resources
	@docker-compose run --rm build terraform apply -var-file="$(VARS)"

auto-apply: prep ## Deploy resources
	@docker-compose run --rm build terraform apply -auto-approve -var-file="$(VARS)"

destroy: prep ## Destroy resources
	@docker-compose run --rm build terraform destroy -var-file="$(VARS)"

setup: ## Set up Python virtual environment and install dependencies.
	@echo "Setting up the Python virtual environment..."
	$(PYTHON) -m venv $(VENV_DIR)
	@echo "Installing dependencies..."
	$(PIP) install pandas pyodbc

run: setup ## Run the data import script.
	@echo "Running the import script..."
	$(VENV_DIR)/bin/$(PYTHON) $(SCRIPT)