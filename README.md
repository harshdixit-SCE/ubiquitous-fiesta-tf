# ubiquitous-fiesta-tf

> Three-tier AWS infrastructure managed with Terraform and deployed via GitHub Actions CI/CD pipeline.

---

## Architecture

```
                          Internet
                             │
                    ┌────────▼────────┐
                    │   Web ALB       │  internet-facing · public subnets · 3 AZs
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Web ASG       │  Amazon Linux 2023 · t3.micro · nginx
                    │  (public, 3AZs) │  reverse proxy → App ALB
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   App ALB       │  internal · private subnets · 3 AZs
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   App ASG       │  Amazon Linux 2023 · t3.micro · nginx
                    │ (private, 3AZs) │  DB connectivity validated on boot
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   RDS MySQL     │  db.t3.micro · private subnets
                    │                 │  credentials in Secrets Manager
                    └─────────────────┘
```

---

## Repository Structure

```
.
├── bootstrap/                  # One-time remote state setup (S3 + DynamoDB)
├── infra/                      # Main infrastructure
│   ├── modules/
│   │   ├── vpc/                # VPC, subnets, IGW, NAT Gateway, route tables
│   │   ├── alb/                # Application Load Balancer + security group
│   │   ├── asg/                # Auto Scaling Group + launch template + IAM role
│   │   └── rds/                # RDS MySQL + Secrets Manager + security group
│   ├── templates/
│   │   ├── app_user_data.sh    # App instance bootstrap script
│   │   └── web_user_data.sh    # Web instance bootstrap (nginx reverse proxy)
│   ├── main.tf                 # Root module — wires all modules together
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values (ALB DNS, VPC ID, etc.)
│   ├── backend.tf              # S3 backend configuration
│   └── providers.tf            # AWS + random provider pinning
├── environments/
│   ├── dev/
│   │   ├── backend.hcl         # Dev state bucket config
│   │   └── dev.tfvars          # Dev variable values
│   └── prod/
│       ├── backend.hcl         # Prod state bucket config
│       └── prod.tfvars         # Prod variable values
├── docs/
│   ├── architecture.md         # Full architecture & configuration reference
│   └── cost-optimization.md    # Cost optimization recommendations
└── .github/workflows/
    ├── bootstrap.yml           # One-time bootstrap workflow
    ├── deploy.yml              # Plan / plan-and-apply
    └── destroy.yml             # Plan-destroy / plan-and-destroy
```

---

## Prerequisites

- AWS account with appropriate permissions
- GitHub repository with the following secret configured:
  - `AWS_ROLE_ARN` — IAM role ARN for GitHub Actions OIDC authentication

> No AWS access keys are stored in GitHub. Authentication uses OpenID Connect (OIDC).

---

## First-Time Setup

### 1. Create the IAM OIDC Role (manual, one-time)

In AWS Console → IAM → Identity Providers, ensure `token.actions.githubusercontent.com` exists.

Create an IAM role with the following trust policy:

```json
{
  "Condition": {
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:harshdixit-SCE/ubiquitous-fiesta-tf:*"
    }
  }
}
```

Add the role ARN as `AWS_ROLE_ARN` in GitHub → Settings → Secrets → Actions.

### 2. Run the Bootstrap Workflow

Go to **Actions → Bootstrap → Run workflow**

| Input | Value |
|-------|-------|
| `state_bucket_name` | `harsh-tf-state-ap-south-1` |
| `aws_region` | `ap-south-1` |
| `action` | `plan-and-apply` |

This creates the S3 state bucket. Only needs to run once.

---

## Deploying Infrastructure

Go to **Actions → Terraform Deploy → Run workflow**

| Input | Description |
|-------|-------------|
| `environment` | `dev` or `prod` |
| `action` | `plan` — shows changes · `plan-and-apply` — applies them |

### Lifecycle

```
Run with action=plan
  → Review plan output in workflow logs
  → Review tfplan artifact (retained 5 days)

Run with action=plan-and-apply
  → Terraform applies the saved plan
```

---

## Destroying Infrastructure

Go to **Actions → Terraform Destroy → Run workflow**

| Input | Description |
|-------|-------------|
| `environment` | `dev` or `prod` |
| `action` | `plan` — shows what will be deleted · `plan-and-destroy` — destroys |
| `confirm` | Must type `DESTROY` when using `plan-and-destroy` |

---

## Local Development

```bash
# Authenticate
aws sso login --profile AdministratorAccess-131578276461

# Init
cd infra
terraform init -backend-config="../environments/dev/backend.hcl"

# Plan
terraform plan -var-file="../environments/dev/dev.tfvars"

# Apply
terraform apply -var-file="../environments/dev/dev.tfvars"
```

---

## Security Controls

| Control | Implementation |
|---------|---------------|
| No static AWS credentials | OIDC — GitHub Actions assumes IAM role via short-lived token |
| No SSH keys | SSM Session Manager — IAM role attached to all instances |
| IMDSv2 enforced | `http_tokens = required` in launch template |
| EBS encryption | `encrypted = true` on all root volumes |
| Secrets management | DB credentials generated and stored in AWS Secrets Manager |
| Network isolation | App/RDS in private subnets — only reachable via ALB |
| Security groups | Each layer only accepts traffic from its upstream SG |

---

## Environments

| Setting | Dev | Prod |
|---------|-----|------|
| Region | ap-south-1 | ap-south-1 |
| RDS Multi-AZ | false | true |
| ASG min/max | 1/2 | 2/4 |
| Skip final snapshot | true | false |
| Secret recovery window | 0 days | 7 days |

---

## Outputs

After a successful apply, the following outputs are available:

| Output | Description |
|--------|-------------|
| `web_alb_dns` | Public URL to access the application |
| `app_alb_dns` | Internal App ALB DNS (for debugging) |
| `vpc_id` | VPC ID |
| `rds_endpoint` | RDS connection endpoint |

```bash
terraform output web_alb_dns
```

---

## Documentation

- [Architecture & Configuration](docs/architecture.md)
- [Cost Optimization Recommendations](docs/cost-optimization.md)
