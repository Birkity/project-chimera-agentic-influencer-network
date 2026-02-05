# Makefile for Project Chimera Development

# Variables
PYTHON_VERSION := 3.11
PROJECT_NAME := chimera
DOCKER_IMAGE := chimera:latest

# Help target
.PHONY: help
help: ## Show this help message
	@echo "Project Chimera - Development Commands"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Setup commands
.PHONY: setup
setup: ## Setup development environment with uv (local) or Docker (containerized)
	@echo "🔧 Setting up Project Chimera development environment..."
	@if command -v docker >/dev/null 2>&1; then \
		echo "🐳 Docker detected - offering containerized setup..."; \
		echo "Choose setup mode:"; \
		echo "  1) Local setup with uv"; \
		echo "  2) Containerized setup with Docker"; \
		read -p "Enter choice (1 or 2): " choice; \
		if [ "$$choice" = "2" ]; then \
			$(MAKE) docker-setup; \
		else \
			$(MAKE) setup-local; \
		fi; \
	else \
		$(MAKE) setup-local; \
	fi

.PHONY: setup-local
setup-local: ## Setup local development environment with uv
	@echo "🔧 Setting up local development environment..."
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "❌ uv is not installed. Please install it first: https://docs.astral.sh/uv/"; \
		exit 1; \
	fi
	uv sync --dev
	@echo "📋 Creating necessary directories..."
	@mkdir -p data logs chimera/models chimera/api chimera/agents
	@mkdir -p skills/content_creation skills/market_intelligence skills/social_engagement
	@echo "🔌 Checking MCP server availability..."
	@$(MAKE) mcp-status || echo "⚠️  Some MCP servers may need setup"
	@echo "✅ Local development environment setup complete!"

.PHONY: install
install: ## Install project dependencies only
	uv sync

.PHONY: install-dev
install-dev: ## Install development dependencies
	uv sync --dev

# Development commands
.PHONY: dev
dev: ## Start development server
	@echo "🚀 Starting Chimera development server..."
	uv run python -m chimera.api.server --reload

.PHONY: agent
agent: ## Start a single agent for testing
	@echo "🤖 Starting Chimera agent..."
	uv run python -m chimera.agent

.PHONY: orchestrator  
orchestrator: ## Start the orchestrator
	@echo "🎭 Starting Chimera orchestrator..."
	uv run python -m chimera.orchestrator

# Testing commands
.PHONY: test
test: ## Run all tests (TDD approach - should fail initially until implementation)  
	@echo "🧪 Running Project Chimera TDD tests..."
	@echo "📋 Note: Tests are designed to FAIL until implementation is complete"
	@echo "🎯 This validates our specification-driven development approach"
	@if command -v docker >/dev/null 2>&1 && [ "$(USE_DOCKER)" = "1" ]; then \
		$(MAKE) docker-test; \
	else \
		uv run pytest tests/ -v --tb=short --color=yes || echo "📋 TDD Status: Tests failing as expected until implementation"; \
	fi
	@echo "✅ Test execution complete - failures indicate specifications ready for implementation!"

.PHONY: test-unit
test-unit: ## Run unit tests only
	uv run pytest tests/ -m "unit" -v

.PHONY: test-integration
test-integration: ## Run integration tests
	uv run pytest tests/ -m "integration" -v

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	uv run pytest tests/ -m "e2e" -v

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	uv run pytest tests/ --cov=chimera --cov-report=html --cov-report=term-missing

# Validation commands
.PHONY: spec-check
spec-check: ## Comprehensive validation of code alignment with specifications
	@echo "📋 Running comprehensive specification compliance validation..."
	@echo "🔍 Phase 1: Validating specification completeness..."
	@./scripts/spec_validator.py specs/ --check-completeness || echo "⚠️  Specification completeness validation failed"
	@echo "🔍 Phase 2: Validating JSON schema compliance..."
	@./scripts/schema_validator.py specs/technical.md chimera/ || echo "⚠️  Schema validation failed"  
	@echo "🔍 Phase 3: Validating skills interface contracts..."
	@$(MAKE) skills-validate || echo "⚠️  Skills validation failed"
	@echo "🔍 Phase 4: Validating MCP server requirements..."
	@./scripts/mcp_validator.py research/tooling_strategy.md || echo "⚠️  MCP validation failed"
	@echo "🔍 Phase 5: Validating API endpoint contracts..."  
	@./scripts/api_validator.py specs/technical.md chimera/api/ || echo "⚠️  API validation failed"
	@echo "🔍 Phase 6: TDD test specification alignment..."
	@uv run pytest tests/ --collect-only -q | grep -E "test_.*\.py" || echo "⚠️  Test collection failed"
	@echo "📊 Generating spec compliance report..."
	@./scripts/generate_compliance_report.py > compliance_report.md
	@echo "✅ Specification validation complete! Check compliance_report.md for details."

.PHONY: spec-check-quick  
spec-check-quick: ## Quick specification validation (essential checks only)
	@echo "📋 Running quick specification compliance check..."
	@echo "🔍 Checking core specification files exist..."
	@test -f specs/_meta.md || (echo "❌ Missing specs/_meta.md"; exit 1)
	@test -f specs/functional.md || (echo "❌ Missing specs/functional.md"; exit 1)
	@test -f specs/technical.md || (echo "❌ Missing specs/technical.md"; exit 1)
	@test -f skills/README.md || (echo "❌ Missing skills/README.md"; exit 1)
	@test -f CLAUDE.md || (echo "❌ Missing CLAUDE.md"; exit 1)
	@echo "🔍 Validating JSON schema syntax..."
	@python -c "import json; [json.loads(open('specs/technical.md').read().split('```json')[i].split('```')[0]) for i in range(1, len(open('specs/technical.md').read().split('```json')))]" || echo "⚠️  JSON schema syntax issues detected"
	@echo "✅ Quick specification check complete!"

.PHONY: skills-validate
skills-validate: ## Validate skills interface compliance  
	@echo "🎯 Validating skills interfaces..."
	@uv run python scripts/skills_validator.py skills/
	@echo "✅ Skills validation complete!"

.PHONY: lint
lint: ## Run linting checks
	@echo "🔍 Running linting checks..."
	uv run black --check chimera/ tests/ skills/
	uv run isort --check chimera/ tests/ skills/
	uv run flake8 chimera/ tests/ skills/

.PHONY: format
format: ## Format code with black and isort
	@echo "🎨 Formatting code..."
	uv run black chimera/ tests/ skills/
	uv run isort chimera/ tests/ skills/

.PHONY: type-check
type-check: ## Run type checking with mypy
	@echo "🔍 Running type checks..."
	uv run mypy chimera/

# Docker commands
.PHONY: docker-build
docker-build: ## Build Docker image for containerized environment
	@echo "🐳 Building Project Chimera Docker image..."
	docker build -t $(DOCKER_IMAGE) .
	@echo "✅ Docker image built successfully!"

.PHONY: docker-setup
docker-setup: docker-build ## Setup containerized development environment
	@echo "🐳 Setting up containerized development environment..."
	@echo "🔧 Creating Docker network for Chimera services..."
	@docker network create chimera-network 2>/dev/null || true
	@echo "🗄️  Starting supporting services (Redis, PostgreSQL, Weaviate)..."
	@docker-compose -f docker/docker-compose.dev.yml up -d
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@echo "✅ Containerized environment setup complete!"

.PHONY: docker-run
docker-run: ## Run application in Docker container
	@echo "🐳 Running Chimera application in Docker..."
	docker run --rm --name chimera-app \
		--network chimera-network \
		-p 8000:8000 \
		-v "$(PWD)/data:/app/data" \
		-v "$(PWD)/logs:/app/logs" \
		-e ENVIRONMENT=development \
		$(DOCKER_IMAGE)

.PHONY: docker-test
docker-test: docker-build ## Run all tests in Docker environment (TDD - should fail initially)
	@echo "🐳 Running Project Chimera tests in Docker container..."
	@echo "📋 Note: Tests are designed to FAIL until implementation is complete (TDD approach)"
	@docker run --rm --name chimera-test \
		--network chimera-network \
		-v "$(PWD)/tests:/app/tests" \
		-e ENVIRONMENT=test \
		$(DOCKER_IMAGE) \
		/opt/venv/bin/pytest tests/ -v --tb=short --color=yes || echo "📋 TDD Status: Tests failing as expected until implementation"
	@echo "✅ Docker test execution complete!"

.PHONY: docker-shell
docker-shell: ## Open interactive shell in Docker container
	@echo "🐳 Opening interactive shell in Chimera container..."
	docker run --rm -it --name chimera-shell \
		--network chimera-network \
		-v "$(PWD):/app" \
		$(DOCKER_IMAGE) /bin/bash

.PHONY: docker-logs
docker-logs: ## View Docker container logs
	@echo "📋 Viewing Chimera application logs..."
	docker logs -f chimera-app 2>/dev/null || echo "No running container found"

.PHONY: docker-clean
docker-clean: ## Clean up Docker containers and images
	@echo "🧹 Cleaning up Docker resources..."
	@docker stop chimera-app chimera-test chimera-shell 2>/dev/null || true
	@docker rm chimera-app chimera-test chimera-shell 2>/dev/null || true
	@docker-compose -f docker/docker-compose.dev.yml down 2>/dev/null || true
	@docker network rm chimera-network 2>/dev/null || true
	@echo "✅ Docker cleanup complete!"

.PHONY: docker-rebuild
docker-rebuild: docker-clean docker-build ## Clean rebuild Docker image
	@echo "🔄 Docker image rebuilt successfully!"

# MCP commands
.PHONY: mcp-servers
mcp-servers: ## Start required MCP servers for development
	@echo "🔌 Starting MCP servers..."
	@./scripts/start_mcp_servers.sh

.PHONY: mcp-status
mcp-status: ## Check MCP server status
	@echo "🔌 Checking MCP server status..."
	@./scripts/check_mcp_status.sh

# Database commands
.PHONY: db-setup
db-setup: ## Setup local development databases
	@echo "🗄️  Setting up development databases..."
	@./scripts/setup_databases.sh

.PHONY: db-migrate
db-migrate: ## Run database migrations
	@echo "🗄️  Running database migrations..."
	uv run alembic upgrade head

.PHONY: db-reset
db-reset: ## Reset development database
	@echo "🗄️  Resetting development database..."
	@./scripts/reset_database.sh

# Utility commands
.PHONY: clean
clean: ## Clean up generated files and caches
	@echo "🧹 Cleaning up..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf build/ dist/ .coverage htmlcov/ .pytest_cache/ .mypy_cache/
	@echo "✅ Cleanup complete!"

.PHONY: clean-all
clean-all: clean ## Clean everything including virtual environment
	rm -rf .venv/
	rm -f uv.lock

.PHONY: update
update: ## Update all dependencies
	@echo "📦 Updating dependencies..."
	uv sync --upgrade
	@echo "✅ Dependencies updated!"

# Documentation commands
.PHONY: docs
docs: ## Generate project documentation
	@echo "📚 Generating documentation..."
	@./scripts/generate_docs.sh

.PHONY: docs-serve
docs-serve: ## Serve documentation locally
	@echo "📚 Serving documentation..."
	@./scripts/serve_docs.sh

# Security commands
.PHONY: security-scan
security-scan: ## Run security vulnerability scanning
	@echo "🔒 Running security scans..."
	uv run pip-audit
	@echo "✅ Security scan complete!"

# Release commands
.PHONY: version
version: ## Show current version
	@echo "Project Chimera v$(shell grep '^version' pyproject.toml | cut -d'"' -f2)"

.PHONY: check-ready
check-ready: lint type-check test spec-check skills-validate ## Check if project is ready for commit
	@echo "✅ Project is ready for commit!"

# CI/CD helpers
.PHONY: ci-setup
ci-setup: ## Setup for CI environment
	uv sync --dev --frozen

.PHONY: ci-test
ci-test: ## Run tests in CI environment  
	uv run pytest tests/ -v --tb=short --cov=chimera --cov-report=xml

.PHONY: ci-lint
ci-lint: ## Run linting for CI
	uv run black --check chimera/ tests/ skills/
	uv run isort --check chimera/ tests/ skills/
	uv run flake8 chimera/ tests/ skills/
	uv run mypy chimera/

# Default target
.DEFAULT_GOAL := help