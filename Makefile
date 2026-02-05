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
setup: ## Setup development environment with uv
	@echo "🔧 Setting up Project Chimera development environment..."
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "❌ uv is not installed. Please install it first: https://docs.astral.sh/uv/"; \
		exit 1; \
	fi
	uv sync --dev
	@echo "✅ Development environment setup complete!"

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
test: ## Run all tests (should fail initially - TDD approach)
	@echo "🧪 Running Project Chimera tests..."
	uv run pytest tests/ -v --tb=short

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
spec-check: ## Validate code alignment with specifications
	@echo "📋 Validating specification compliance..."
	@uv run python scripts/spec_validator.py specs/ chimera/
	@echo "✅ Specification validation complete!"

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
.PHONY: build
build: ## Build Docker image
	@echo "🐳 Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .

.PHONY: run-docker
run-docker: ## Run application in Docker
	@echo "🐳 Running Chimera in Docker..."
	docker run --rm -p 8000:8000 $(DOCKER_IMAGE)

.PHONY: test-docker
test-docker: ## Run tests in Docker environment
	@echo "🐳 Running tests in Docker..."
	docker run --rm $(DOCKER_IMAGE) uv run pytest tests/ -v

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