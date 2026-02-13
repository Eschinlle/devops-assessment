.PHONY: help install test lint format type-check security clean docker-build docker-up docker-down k8s-deploy k8s-delete terraform-init terraform-apply terraform-destroy run dev docs

PYTHON := python3
PIP := pip3
PYTEST := pytest
DOCKER_COMPOSE := docker compose
KUBECTL := kubectl
TERRAFORM := terraform
IMAGE_NAME := devops-microservice
IMAGE_TAG := latest
NAMESPACE := devops

GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m 

help:
	@echo "$(GREEN)DevOps Microservice - Makefile Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

install: 
	@echo "$(GREEN)Installing dependencies...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependencies installed$(NC)"

install-dev: install 
	@echo "$(GREEN)Installing development dependencies...$(NC)"
	$(PIP) install pytest pytest-cov pytest-watch pylint black mypy bandit safety flake8
	@echo "$(GREEN)Development dependencies installed$(NC)"

run: 
	@echo "$(GREEN)Starting application...$(NC)"
	uvicorn app.main:app --host 0.0.0.0 --port 8000

dev: 
	@echo "$(GREEN)Starting application in development mode...$(NC)"
	uvicorn app.main:app --reload --log-level debug

test: 
	@echo "$(GREEN)Running tests...$(NC)"
	$(PYTEST) --cov=app --cov-report=html --cov-report=term-missing
	@echo "$(GREEN)Tests completed$(NC)"
	@echo "$(YELLOW)Open htmlcov/index.html to view coverage report$(NC)"

test-verbose: 
	@echo "$(GREEN)Running tests (verbose)...$(NC)"
	$(PYTEST) -vv --cov=app --cov-report=term-missing

test-watch:
	@echo "$(GREEN)Running tests in watch mode...$(NC)"
	pytest-watch -- --cov=app

test-endpoint: 
	@echo "$(GREEN)Running endpoint tests...$(NC)"
	@chmod +x test-endpoint.sh
	./test-endpoint.sh

lint: 
	@echo "$(GREEN)Running pylint...$(NC)"
	pylint app/ --exit-zero
	@echo "$(GREEN)Linting completed$(NC)"

format: 
	@echo "$(GREEN)Formatting code...$(NC)"
	black app/ tests/
	@echo "$(GREEN)Code formatted$(NC)"

format-check: 
	@echo "$(GREEN)Checking code formatting...$(NC)"
	black --check app/ tests/

type-check: 
	@echo "$(GREEN)Running type checking...$(NC)"
	mypy app/ --ignore-missing-imports
	@echo "$(GREEN)Type checking completed$(NC)"

security: 
	@echo "$(GREEN)Running security checks...$(NC)"
	bandit -r app/ -f json -o bandit-report.json || true
	@echo "$(YELLOW)Bandit report saved to bandit-report.json$(NC)"
	safety check --json || true
	@echo "$(GREEN)Security checks completed$(NC)"

quality: lint format-check type-check security 

docker-build: 
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "$(GREEN)Docker image built: $(IMAGE_NAME):$(IMAGE_TAG)$(NC)"

docker-up: 
	@echo "$(GREEN)Starting Docker containers...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Containers started$(NC)"
	@echo "$(YELLOW)Access the application at: http://localhost:8080$(NC)"

docker-down: 
	@echo "$(GREEN)Stopping Docker containers...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Containers stopped$(NC)"

docker-logs:
	$(DOCKER_COMPOSE) logs -f

docker-ps: 
	$(DOCKER_COMPOSE) ps

docker-restart: docker-down docker-up 

docker-clean: docker-down 
	@echo "$(GREEN)Cleaning Docker resources...$(NC)"
	docker system prune -f
	@echo "$(GREEN)Docker resources cleaned$(NC)"

k8s-deploy: 
	@echo "$(GREEN)Deploying to Kubernetes...$(NC)"
	$(KUBECTL) apply -f k8s/
	@echo "$(GREEN)Deployed to Kubernetes$(NC)"
	@echo "$(YELLOW)Run 'make k8s-status' to check deployment status$(NC)"

k8s-delete: 
	@echo "$(GREEN)Deleting Kubernetes resources...$(NC)"
	$(KUBECTL) delete -f k8s/
	@echo "$(GREEN)Kubernetes resources deleted$(NC)"

k8s-status: 
	@echo "$(GREEN)Checking Kubernetes status...$(NC)"
	$(KUBECTL) get all -n $(NAMESPACE)

k8s-logs:
	$(KUBECTL) logs -f deployment/devops-microservice -n $(NAMESPACE)

k8s-describe: 
	$(KUBECTL) describe deployment devops-microservice -n $(NAMESPACE)

k8s-port-forward:
	@echo "$(GREEN)Port forwarding to Kubernetes service...$(NC)"
	@echo "$(YELLOW)Access the application at: http://localhost:8080$(NC)"
	$(KUBECTL) port-forward svc/devops-microservice-service 8080:80 -n $(NAMESPACE)

k8s-scale: 
	@echo "$(GREEN)Scaling deployment to $(REPLICAS) replicas...$(NC)"
	$(KUBECTL) scale deployment devops-microservice --replicas=$(REPLICAS) -n $(NAMESPACE)

k8s-restart:
	@echo "$(GREEN)Restarting deployment...$(NC)"
	$(KUBECTL) rollout restart deployment/devops-microservice -n $(NAMESPACE)

k8s-hpa: 
	$(KUBECTL) get hpa -n $(NAMESPACE)
	$(KUBECTL) describe hpa devops-microservice-hpa -n $(NAMESPACE)

terraform-init: 
	@echo "$(GREEN)Initializing Terraform...$(NC)"
	cd terraform && $(TERRAFORM) init
	@echo "$(GREEN)Terraform initialized$(NC)"

terraform-plan: 
	@echo "$(GREEN)Planning Terraform changes...$(NC)"
	cd terraform && $(TERRAFORM) plan

terraform-apply: 
	@echo "$(GREEN)Applying Terraform changes...$(NC)"
	cd terraform && $(TERRAFORM) apply
	@echo "$(GREEN)Terraform changes applied$(NC)"

terraform-destroy: 
	@echo "$(RED)Destroying Terraform resources...$(NC)"
	cd terraform && $(TERRAFORM) destroy
	@echo "$(GREEN)Terraform resources destroyed$(NC)"

terraform-output: 
	cd terraform && $(TERRAFORM) output

terraform-validate: 
	@echo "$(GREEN)Validating Terraform configuration...$(NC)"
	cd terraform && $(TERRAFORM) validate
	@echo "$(GREEN)Terraform configuration is valid$(NC)"

terraform-fmt: 
	@echo "$(GREEN)Formatting Terraform files...$(NC)"
	cd terraform && $(TERRAFORM) fmt -recursive
	@echo "$(GREEN)Terraform files formatted$(NC)"

docs: 
	@echo "$(GREEN)Opening API documentation...$(NC)"
	@echo "$(YELLOW)Visit: http://localhost:8000/docs$(NC)"
	@command -v open >/dev/null 2>&1 && open http://localhost:8000/docs || \
	command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:8000/docs || \
	echo "$(YELLOW)Please open http://localhost:8000/docs in your browser$(NC)"

coverage-report: 
	@echo "$(GREEN)Opening coverage report...$(NC)"
	@command -v open >/dev/null 2>&1 && open htmlcov/index.html || \
	command -v xdg-open >/dev/null 2>&1 && xdg-open htmlcov/index.html || \
	echo "$(YELLOW)Please open htmlcov/index.html in your browser$(NC)"

clean: 
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type f -name ".coverage" -delete 2>/dev/null || true
	rm -rf htmlcov/ 2>/dev/null || true
	rm -rf .pytest_cache/ 2>/dev/null || true
	rm -rf bandit-report.json 2>/dev/null || true
	@echo "$(GREEN)Cleanup completed$(NC)"

clean-all: clean docker-clean 

ci: quality test 

setup: install-dev
	@echo "$(GREEN)Setup completed$(NC)"
	@echo "$(YELLOW)Run 'make dev' to start the development server$(NC)"

all: quality test docker-build 

quick-test: 
	$(PYTEST) -x

quick-start: 
	@make install
	@make dev
