# =============================================================================
# AWS Bootstrap Infrastructure - Makefile
# =============================================================================

.PHONY: help bootstrap-init bootstrap-plan bootstrap-apply bootstrap-output setup-backend sync-env

# Default target
help:
	@echo "AWS Bootstrap Infrastructure Commands"
	@echo ""
	@echo "Bootstrap (one-time setup):"
	@echo "  make bootstrap-init          Initialize bootstrap Terraform"
	@echo "  make bootstrap-plan          Plan bootstrap changes"
	@echo "  make bootstrap-apply         Apply bootstrap infrastructure"
	@echo "  make bootstrap-output        Show bootstrap outputs"
	@echo "  make bootstrap-destroy       Destroy bootstrap infrastructure (DANGER!)"
	@echo ""
	@echo "Setup:"
	@echo "  make setup-backend           Generate backend configs for application Terraform"
	@echo "  make setup-workflows         Generate GitHub Actions workflows"
	@echo "  make setup-pre-commit        Setup pre-commit hooks (Ruff + Pyright)"
	@echo "  make sync-env                Sync terraform.tfvars to .env file"
	@echo ""
	@echo "Application (per environment):"
	@echo "  make app-init-dev            Initialize application Terraform for dev"
	@echo "  make app-init-test           Initialize application Terraform for test"
	@echo "  make app-init-prod           Initialize application Terraform for prod"
	@echo "  make app-plan-dev            Plan application changes for dev"
	@echo "  make app-apply-dev           Apply application infrastructure to dev"
	@echo ""
	@echo "Python Code Quality:"
	@echo "  make lint                    Check code with Ruff"
	@echo "  make lint-fix                Auto-fix issues with Ruff"
	@echo "  make typecheck               Type check with Pyright"
	@echo "  make test                    Run tests with pytest"
	@echo "  make pre-commit-all          Run all pre-commit hooks"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build            Build Docker image with uv"
	@echo "  make docker-push-dev         Push Docker image to dev ECR"
	@echo ""
	@echo "Utilities:"
	@echo "  make format-all              Format Python + Terraform"
	@echo "  make clean                   Remove build artifacts"
	@echo ""

# =============================================================================
# Bootstrap Commands
# =============================================================================

bootstrap-init:
	@echo "🔧 Initializing bootstrap Terraform..."
	cd bootstrap && terraform init

bootstrap-plan:
	@echo "📋 Planning bootstrap changes..."
	cd bootstrap && terraform plan

bootstrap-apply:
	@echo "🚀 Applying bootstrap infrastructure..."
	cd bootstrap && terraform apply
	@echo ""
	@echo "✅ Bootstrap complete! Next steps:"
	@echo "   make setup-backend"
	@echo "   make setup-workflows"

bootstrap-output:
	@echo "📊 Bootstrap outputs:"
	cd bootstrap && terraform output

bootstrap-destroy:
	@echo "⚠️  WARNING: This will destroy ALL bootstrap infrastructure!"
	@echo "This includes:"
	@echo "  - S3 state bucket (and all state files)"
	@echo "  - GitHub Actions IAM roles"
	@echo "  - ECR repositories (and all images)"
	@echo "  - EKS cluster (if created)"
	@echo "  - VPC and networking (if created)"
	@echo ""
	@read -p "Are you ABSOLUTELY sure? Type 'yes' to continue: " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		cd bootstrap && terraform destroy; \
	else \
		echo "Cancelled."; \
	fi

# =============================================================================
# Setup Commands
# =============================================================================

setup-backend:
	@echo "📝 Generating Terraform backend configurations..."
	./scripts/setup-terraform-backend.sh

setup-workflows:
	@echo "🔄 Generating GitHub Actions workflows..."
	./scripts/generate-workflows.sh

sync-env:
	@echo "🔄 Syncing terraform.tfvars to .env file..."
	uv run python scripts/sync-tfvars-to-env.py

# =============================================================================
# Application Commands - Dev Environment
# =============================================================================

app-init-dev:
	@echo "🔧 Initializing Terraform for dev environment..."
	cd terraform-app && terraform init -backend-config=environments/dev-backend.hcl

app-plan-dev:
	@echo "📋 Planning changes for dev environment..."
	cd terraform-app && terraform plan -var-file=environments/dev.tfvars

app-apply-dev:
	@echo "🚀 Applying changes to dev environment..."
	cd terraform-app && terraform apply -var-file=environments/dev.tfvars

app-destroy-dev:
	@echo "⚠️  Destroying dev environment infrastructure..."
	cd terraform-app && terraform destroy -var-file=environments/dev.tfvars

# =============================================================================
# Application Commands - Test Environment
# =============================================================================

app-init-test:
	@echo "🔧 Initializing Terraform for test environment..."
	cd terraform-app && terraform init -backend-config=environments/test-backend.hcl -reconfigure

app-plan-test:
	@echo "📋 Planning changes for test environment..."
	cd terraform-app && terraform plan -var-file=environments/test.tfvars

app-apply-test:
	@echo "🚀 Applying changes to test environment..."
	cd terraform-app && terraform apply -var-file=environments/test.tfvars

# =============================================================================
# Application Commands - Prod Environment
# =============================================================================

app-init-prod:
	@echo "🔧 Initializing Terraform for prod environment..."
	cd terraform-app && terraform init -backend-config=environments/prod-backend.hcl -reconfigure

app-plan-prod:
	@echo "📋 Planning changes for prod environment..."
	cd terraform-app && terraform plan -var-file=environments/prod.tfvars

app-apply-prod:
	@echo "🚀 Applying changes to prod environment..."
	cd terraform-app && terraform apply -var-file=environments/prod.tfvars

# =============================================================================
# Docker Commands
# =============================================================================

docker-build:
	@echo "🐳 Building Docker image with uv..."
	docker build -t $(PROJECT_NAME):latest -f Dockerfile .

docker-push-dev:
	@echo "📤 Pushing Docker image to dev ECR..."
	./scripts/docker-push.sh dev

docker-push-test:
	@echo "📤 Pushing Docker image to test ECR..."
	./scripts/docker-push.sh test

docker-push-prod:
	@echo "📤 Pushing Docker image to prod ECR..."
	./scripts/docker-push.sh prod

# =============================================================================
# Python Code Quality Commands
# =============================================================================

setup-pre-commit:
	@echo "🔧 Setting up pre-commit hooks..."
	./scripts/setup-pre-commit.sh

lint:
	@echo "🔍 Checking code quality with Ruff..."
	uv run ruff check src/ tests/

lint-fix:
	@echo "🔧 Auto-fixing issues with Ruff..."
	uv run ruff check --fix src/ tests/
	uv run ruff format src/ tests/

format-python:
	@echo "🎨 Formatting Python code with Ruff..."
	uv run ruff format src/ tests/

typecheck:
	@echo "🔎 Type checking with Pyright..."
	uv run pyright src/

test:
	@echo "🧪 Running tests..."
	uv run pytest tests/ -v --cov=src --cov-report=term-missing

test-watch:
	@echo "👀 Running tests in watch mode..."
	uv run pytest-watch tests/ -v

pre-commit-all:
	@echo "🪝 Running pre-commit on all files..."
	uv run pre-commit run --all-files

pre-commit-update:
	@echo "⬆️  Updating pre-commit hooks..."
	uv run pre-commit autoupdate

# =============================================================================
# Terraform Utility Commands
# =============================================================================

format-terraform:
	@echo "🎨 Formatting Terraform files..."
	terraform fmt -recursive bootstrap/
	terraform fmt -recursive terraform-app/

format-all: format-terraform format-python
	@echo "✅ Formatted all files"

validate:
	@echo "✅ Validating Terraform configurations..."
	cd bootstrap && terraform validate
	cd terraform-app && terraform validate

clean:
	@echo "🧹 Cleaning artifacts..."
	@echo "   Cleaning Terraform..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "   Cleaning Python..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".coverage" -delete 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Done!"
