# AWS Bootstrap Infrastructure

> **A starter for Python cloud applications on AWS**
>
> Complete, modular infrastructure with Lambda, App Runner, or EKS. Start simple with serverless, scale to Kubernetes when needed.

A production-ready Infrastructure as Code (IaC) template for bootstrapping AWS projects. Supports Python 3.13 with `uv` for fast dependency management, GitHub Actions CI/CD via OIDC, and Terraform state management in S3.

**📖 New to this project?** Start with the [Terraform Bootstrap Guide](docs/TERRAFORM-BOOTSTRAP.md) for a complete walkthrough.

## 🚀 Features

### Compute Options (Choose Your Stack)
- **✅ Lambda** - Serverless functions with container images (default)
- **🌐 App Runner** - Fully managed containerized web applications
- **☸️ EKS** - Complete Kubernetes cluster with auto-scaling and ALB ingress

### Core Capabilities
- **📦 Python 3.13 + uv** - Latest Python with ultra-fast dependency management
- **🔐 GitHub OIDC** - Secure, credential-less CI/CD authentication
- **🗄️ S3 State Management** - Self-referencing Terraform state with locking
- **🎯 Multi-Environment** - Dev, test, and prod environments
- **🐳 Container-Ready** - ECR repositories with vulnerability scanning
- **🌐 Optional VPC** - Private networking for EKS or App Runner

### Infrastructure Included
- S3 bucket for Terraform state (versioned, encrypted)
- GitHub Actions OIDC provider
- IAM roles per environment (dev, test, prod)
- ECR repositories (conditional)
- Lambda execution roles (conditional)
- App Runner access & instance roles (conditional)
- EKS cluster with node groups (conditional)
- VPC with public/private subnets (conditional)

---

## 📋 Prerequisites

- **AWS Account** with administrative access
- **Terraform** >= 1.13.0
- **AWS CLI** configured (`aws configure`)
- **GitHub Repository** for your project
- **uv** (for Python development): `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Make** (optional, for convenience commands)

---

## 🏗️ Architecture

```
┌───────────────────────────────────────────────────────────────┐
│  AWS Account                                                  │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ Bootstrap Infrastructure (One-Time Setup)              │   │
│  │                                                        │   │
│  │  • S3 State Bucket (versioned, encrypted)              │   │
│  │  • GitHub OIDC Provider                                │   │
│  │  • IAM Roles (dev, test, prod)                         │   │
│  │  • ECR Repositories (if containers enabled)            │   │
│  │  • VPC & Networking (if EKS enabled)                   │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ Application Infrastructure (Per Environment)           │   │
│  │                                                        │   │
│  │  • Lambda Functions (if enabled)                       │   │
│  │  • App Runner Services (if enabled)                    │   │
│  │  • EKS Workloads (if enabled)                          │   │
│  └────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### 1. Clone and Configure

```bash
# Clone this repository
git clone <your-repo>
cd aws-base-python

# Copy and customize configuration
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
```

### 2. Edit Configuration

Edit `bootstrap/terraform.tfvars`:

```hcl
# Required: Change these values
project_name = "my-project"       # Your project name (lowercase, hyphens only)
github_org   = "my-github-org"    # Your GitHub org or username
github_repo  = "my-repo"          # Your repository name

# Choose your compute stack
enable_lambda    = true    # ✅ Default: Serverless functions
enable_apprunner = false   # 🌐 Containerized web apps
enable_eks       = false   # ☸️ Kubernetes cluster

# Python configuration
python_version = "3.13"
use_uv_builder = true
```

### 3. Deploy Bootstrap

```bash
# Initialize Terraform
make bootstrap-init

# Review changes
make bootstrap-plan

# Apply infrastructure
make bootstrap-apply

# Generate backend configs
make setup-backend

# Sync outputs to .env (for shell scripts, Docker)
make sync-env
```

### 4. Configure GitHub

After bootstrap completes, configure your GitHub repository:

#### Repository Secrets
```bash
AWS_ACCOUNT_ID=<your-account-id>
AWS_REGION=us-east-1
```

#### Repository Variables
```bash
PROJECT_NAME=my-project
TERRAFORM_STATE_BUCKET=my-project-terraform-state-<account-id>
```

#### Environments
Create GitHub environments and add role ARNs:
- **dev**: Add `AWS_ROLE_ARN_DEV` (from bootstrap output)
- **test**: Add `AWS_ROLE_ARN_TEST` (if enabled)
- **production**: Add `AWS_ROLE_ARN_PROD`

### 5. Deploy Application (Optional)

```bash
# Initialize application Terraform
make app-init-dev

# Deploy to dev
make app-plan-dev
make app-apply-dev
```

---

## 📝 Configuration Examples

### Example 1: Simple Lambda API

```hcl
# bootstrap/terraform.tfvars
project_name = "my-api"
github_org   = "mycompany"
github_repo  = "my-api"

enable_lambda    = true
enable_apprunner = false
enable_eks       = false

lambda_use_container_image = true
python_version = "3.13"
```

**Result**: Lambda functions with ECR for container images

---

### Example 2: Containerized Web App (App Runner)

```hcl
project_name = "my-webapp"
github_org   = "mycompany"
github_repo  = "my-webapp"

enable_lambda    = false
enable_apprunner = true
enable_eks       = false

ecr_repositories = ["web", "worker"]
python_version   = "3.13"
```

**Result**: App Runner service with ECR repositories

---

### Example 3: Microservices Platform (EKS)

```hcl
project_name = "platform"
github_org   = "mycompany"
github_repo  = "platform"

enable_lambda = false
enable_apprunner = false
enable_eks    = true

eks_cluster_version     = "1.31"
eks_node_instance_types = ["t3.medium"]
ecr_repositories        = ["auth", "api", "data-processor"]

create_vpc = true
vpc_availability_zones = 3
```

**Result**: Complete EKS cluster with VPC, ECR, and IAM roles

---

### Example 4: Hybrid (Lambda + App Runner)

```hcl
project_name = "hybrid-app"
github_org   = "mycompany"
github_repo  = "hybrid-app"

enable_lambda    = true
enable_apprunner = true
enable_eks       = false

ecr_repositories = ["web-frontend"]
lambda_use_container_image = true
python_version = "3.13"
```

**Result**: Both Lambda and App Runner infrastructure

---

## 🐍 Python Development with uv

### Initialize Project

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create new project
cp pyproject.toml.example pyproject.toml

# Initialize uv
uv init

# Install dependencies
uv sync

# Add a package
uv add fastapi uvicorn boto3

# Add dev dependencies
uv add --dev pytest black ruff
```

### Project Structure

```
my-project/
├── src/
│   ├── __init__.py
│   └── main.py          # Application entry point
├── tests/
│   └── test_main.py
├── pyproject.toml       # Project configuration
├── uv.lock             # Locked dependencies (commit to git)
├── Dockerfile.lambda    # Lambda container
├── Dockerfile.apprunner # App Runner container
└── Dockerfile.eks       # EKS container
```

### Build Containers

```bash
# Lambda
docker build -f Dockerfile.lambda -t my-project:lambda .

# App Runner
docker build -f Dockerfile.apprunner -t my-project:apprunner .

# EKS
docker build -f Dockerfile.eks -t my-project:eks .
```

---

## 🔧 Make Commands

### Bootstrap
```bash
make bootstrap-init      # Initialize Terraform
make bootstrap-plan      # Plan changes
make bootstrap-apply     # Apply infrastructure
make bootstrap-output    # Show outputs
make bootstrap-destroy   # Destroy (DANGER!)
```

### Setup
```bash
make setup-backend      # Generate backend configs
make setup-workflows    # Generate GitHub Actions workflows
```

### Application
```bash
make app-init-dev       # Initialize dev environment
make app-plan-dev       # Plan dev changes
make app-apply-dev      # Deploy to dev
```

### Docker
```bash
make docker-build       # Build Docker image
make docker-push-dev    # Push to dev ECR
```

---

## 📁 Directory Structure

```
aws-base/
├── bootstrap/              # Bootstrap infrastructure
│   ├── main.tf               # Core resources (S3, OIDC, IAM)
│   ├── lambda.tf             # Lambda resources (conditional)
│   ├── apprunner.tf          # App Runner resources (conditional)
│   ├── eks.tf                # EKS resources (conditional)
│   ├── ecr.tf                # ECR repositories (conditional)
│   ├── networking.tf         # VPC resources (conditional)
│   ├── variables.tf          # All configuration options
│   ├── outputs.tf            # Bootstrap outputs
│   ├── terraform.tfvars      # Your configuration (gitignored)
│   └── terraform.tfvars.example
│
├── terraform-app/            # Application infrastructure
│   ├── backend.tf            # S3 backend configuration
│   ├── main.tf               # Provider and resources
│   ├── environments/
│   │   ├── dev.tfvars
│   │   ├── dev-backend.hcl   # Generated by setup script
│   │   ├── test.tfvars
│   │   └── prod.tfvars
│   └── modules/              # Reusable modules
│       ├── lambda-function/
│       ├── apprunner-service/
│       └── eks-workload/
│
├── scripts/
│   ├── setup-terraform-backend.sh  # Generate backend configs
│   └── generate-workflows.sh       # Generate GitHub Actions
│
├── Dockerfile.lambda         # Lambda container
├── Dockerfile.apprunner      # App Runner container
├── Dockerfile.eks            # EKS container
├── pyproject.toml.example    # Python project template
├── Makefile                  # Convenience commands
└── README.md                 # This file
```

---

## 🔐 Security Best Practices

### Implemented
- ✅ S3 bucket encryption (AES256)
- ✅ S3 versioning enabled
- ✅ S3 public access blocked
- ✅ GitHub OIDC (no long-lived credentials)
- ✅ IAM least-privilege policies
- ✅ ECR vulnerability scanning
- ✅ VPC private subnets
- ✅ Security groups with minimal access

### Recommendations
- 🔒 Enable `prevent_destroy` on state bucket after first apply
- 🔒 Use AWS Secrets Manager for sensitive configuration
- 🔒 Enable CloudTrail for audit logging
- 🔒 Set up AWS Config for compliance
- 🔒 Enable GuardDuty for threat detection
- 🔒 Review IAM policies regularly

---

## 🎯 Use Cases

### Lambda (Serverless Functions)
**Best for:**
- REST APIs (API Gateway + Lambda)
- Background jobs and event processing
- Scheduled tasks (EventBridge + Lambda)
- Image/video processing
- Data transformation

**Limitations:**
- 15-minute execution limit
- 10GB memory limit
- Cold start latency

---

### App Runner (Containerized Web Apps)
**Best for:**
- Web applications and APIs
- Microservices
- Simple containerized workloads
- Auto-scaling web services

**Advantages:**
- No infrastructure management
- Built-in HTTPS
- Auto-scaling
- Simple deployment

**Limitations:**
- Regional service (not all regions)
- Less control than EKS

---

### EKS (Kubernetes)
**Best for:**
- Complex microservices
- Multi-container applications
- Existing Kubernetes expertise
- Advanced networking requirements
- Stateful applications

**Considerations:**
- Higher complexity
- More expensive
- Requires Kubernetes knowledge

---

## 📊 Cost Estimates

### Lambda
- **Compute**: $0.0000166667 per GB-second (arm64)
- **Requests**: $0.20 per 1M requests
- **Free tier**: 1M requests/month, 400,000 GB-seconds/month
- **Typical cost**: $5-50/month for small apps

### App Runner
- **Compute**: $0.064/vCPU-hour + $0.007/GB-hour
- **Build**: $0.005/build minute
- **Data transfer**: $0.09/GB out
- **Typical cost**: $20-100/month (1 vCPU, 2GB)

### EKS
- **Control plane**: $0.10/hour ($73/month)
- **Nodes**: EC2 pricing (t3.medium: ~$30/month each)
- **NAT Gateway**: $0.045/hour per AZ ($32/month each)
- **Typical cost**: $150-500/month (small cluster)

### Shared Costs
- **S3 state bucket**: $0.023/GB-month (negligible)
- **ECR storage**: $0.10/GB-month
- **ECR data transfer**: Free to Lambda/ECS/App Runner in same region

---

## 🆘 Troubleshooting

### Bootstrap fails with "bucket already exists"
**Solution**: The S3 bucket name must be globally unique. Change `state_bucket_name` in `terraform.tfvars`.

### Cannot assume GitHub Actions role
**Solution**:
1. Verify GitHub environment names match Terraform (dev, test, production)
2. Check repository name matches `github_repo` variable
3. Ensure OIDC provider thumbprint is current

### EKS nodes not joining cluster
**Solution**:
1. Check security group allows node-to-control-plane communication
2. Verify IAM roles have correct policies attached
3. Check VPC has internet access (NAT gateway for private subnets)

### Lambda container image too large
**Solution**:
1. Use multi-stage Docker builds
2. Remove unnecessary dependencies from `pyproject.toml`
3. Consider Lambda layers for shared dependencies
4. Use `--no-cache` in `uv sync`

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

MIT License - see LICENSE file for details

---

## 🙏 Acknowledgments

- Built with [Terraform](https://www.terraform.io/)
- Python dependency management by [uv](https://github.com/astral-sh/uv)
- Inspired by AWS best practices and community contributions

---

## 📚 Documentation

### Project Documentation

This repository includes comprehensive documentation for all aspects of the bootstrap and development workflow:

#### 🏗️ Infrastructure & Deployment

- **[📖 Terraform Bootstrap Guide](docs/TERRAFORM-BOOTSTRAP.md)** - Complete guide to the bootstrap infrastructure
  - What resources are created and why
  - Configuration examples for all use cases
  - Step-by-step deployment instructions
  - State management strategy
  - Security best practices
  - Cost breakdown and estimates
  - Troubleshooting guide

- **[📈 Incremental Adoption](docs/INCREMENTAL-ADOPTION.md)** - How to start small and scale
  - Start with Lambda, add EKS later
  - Phase-by-phase migration guides
  - Cost evolution across phases
  - Decision matrices for choosing compute options
  - Safety guarantees (what never changes)

#### 🛠️ Development Tools

- **[✅ Pre-commit Hooks](docs/PRE-COMMIT.md)** - Automated code quality
  - Ruff (linting + formatting) setup
  - Pyright (type checking) configuration
  - Installation and usage guide
  - Rule explanations
  - Troubleshooting

- **[⚙️ Scripts Documentation](docs/SCRIPTS.md)** - Automation scripts
  - `setup-terraform-backend.sh` - Generate backend configs
  - `generate-workflows.sh` - Create GitHub Actions workflows
  - `docker-push.sh` - Build and push Docker images
  - `setup-pre-commit.sh` - Install code quality hooks

#### 📋 Quick Reference

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [README.md](README.md) | Overview and quick start | **Start here** |
| [TERRAFORM-BOOTSTRAP.md](docs/TERRAFORM-BOOTSTRAP.md) | Infrastructure deep dive | Before deploying bootstrap |
| [INCREMENTAL-ADOPTION.md](docs/INCREMENTAL-ADOPTION.md) | Scaling strategy | Planning architecture evolution |
| [PRE-COMMIT.md](docs/PRE-COMMIT.md) | Code quality setup | Setting up development environment |
| [SCRIPTS.md](docs/SCRIPTS.md) | Automation reference | Using helper scripts |

### External Resources

- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [App Runner Documentation](https://docs.aws.amazon.com/apprunner/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [uv Documentation](https://docs.astral.sh/uv/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Pyright Documentation](https://microsoft.github.io/pyright/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 📞 Support

For issues and questions:
- 🐛 [Open an Issue](https://github.com/your-org/your-repo/issues)
- 💬 [Discussions](https://github.com/your-org/your-repo/discussions)
- 📖 [Documentation](https://github.com/your-org/your-repo/wiki)

---

**Built with ❤️ for the AWS + Python community**
