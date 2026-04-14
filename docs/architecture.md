# Infrastructure Architecture & Configuration

**Author:** Harsh Dixit  
**Date:** April 2026  
**Environment:** AWS (ap-south-1)  
**Managed By:** Terraform + GitHub Actions  

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Network Layer](#network-layer)
4. [Web Layer](#web-layer)
5. [Application Layer](#application-layer)
6. [Database Layer](#database-layer)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Security](#security)
9. [High Availability](#high-availability)
10. [Cost Optimization](#cost-optimization)

---

## Overview

This document describes the infrastructure deployed on AWS for a three-tier web application. The architecture follows AWS best practices for security, high availability, and cost efficiency. All infrastructure is managed as code using Terraform and deployed via GitHub Actions.

### Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| IaC Tool | Terraform | Industry standard, reusable modules |
| CI/CD | GitHub Actions + OIDC | No static credentials, secure by default |
| State Backend | S3 + native locking | No DynamoDB dependency, simpler setup |
| OS | Amazon Linux 2023 | AWS-optimized, latest security patches |
| Instance Access | SSM Session Manager | No bastion host, no SSH keys required |

---

## Architecture Diagram

```
                          Internet
                             │
                             ▼
                    ┌─────────────────┐
                    │   Web ALB       │  (internet-facing, public subnets)
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │ Web ASG  │  │ Web ASG  │  │ Web ASG  │  (public subnets, 3 AZs)
        │  AZ-1    │  │  AZ-2    │  │  AZ-3    │
        └──────────┘  └──────────┘  └──────────┘
                             │
                    ┌─────────────────┐
                    │   App ALB       │  (internal, private subnets)
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │ App ASG  │  │ App ASG  │  │ App ASG  │  (private subnets, 3 AZs)
        │  AZ-1    │  │  AZ-2    │  │  AZ-3    │
        └──────────┘  └──────────┘  └──────────┘
                             │
                    ┌─────────────────┐
                    │  RDS MySQL      │  (private subnets, Multi-AZ)
                    │  Primary/StandBy│
                    └─────────────────┘
```

---

## Network Layer

### VPC Configuration

| Resource | Value |
|----------|-------|
| VPC CIDR | `10.0.0.0/16` |
| Region | `ap-south-1` |
| Availability Zones | 3 (ap-south-1a, ap-south-1b, ap-south-1c) |

### Subnets

| Type | AZ | CIDR | Usage |
|------|----|------|-------|
| Public | AZ-1 | `10.0.0.0/24` | Web layer, NAT Gateway |
| Public | AZ-2 | `10.0.1.0/24` | Web layer |
| Public | AZ-3 | `10.0.2.0/24` | Web layer |
| Private | AZ-1 | `10.0.10.0/24` | App layer, RDS |
| Private | AZ-2 | `10.0.11.0/24` | App layer, RDS |
| Private | AZ-3 | `10.0.12.0/24` | App layer, RDS |

### Connectivity

- **Internet Gateway** — provides internet access to public subnets
- **NAT Gateway** — provides outbound internet access for private subnets (package installs, SSM)
- **Route Tables** — separate public and private route tables, associated per subnet

---

## Web Layer

### Load Balancer

| Property | Value |
|----------|-------|
| Type | Application Load Balancer (ALB) |
| Scheme | Internet-facing |
| Subnets | 3 public subnets |
| Protocol | HTTP (port 80) |
| Health Check Path | `/health` |

### Auto Scaling Group

| Property | Value |
|----------|-------|
| Instance Type | `t3.micro` |
| AMI | Amazon Linux 2023 (latest) |
| Min / Max / Desired | 1 / 2 / 1 (dev) |
| Scaling Policy | Target CPU tracking at 60% |
| Subnets | 3 public subnets |

### Configuration

- Nginx installed via user data on launch
- Reverse proxies all traffic to the internal App ALB
- `/health` endpoint returns 200 directly from nginx (no proxy) for ALB health checks
- SSM Session Manager enabled — no SSH/bastion required

---

## Application Layer

### Load Balancer

| Property | Value |
|----------|-------|
| Type | Application Load Balancer (ALB) |
| Scheme | Internal |
| Subnets | 3 private subnets |
| Protocol | HTTP (port 80) |
| Health Check Path | `/` |

### Auto Scaling Group

| Property | Value |
|----------|-------|
| Instance Type | `t3.micro` |
| AMI | Amazon Linux 2023 (latest) |
| Min / Max / Desired | 1 / 2 / 1 (dev) |
| Scaling Policy | Target CPU tracking at 60% |
| Subnets | 3 private subnets |

### Configuration

- Nginx installed via user data on launch
- DB connectivity validated on boot — result logged to `/var/log/db-connectivity.log`
- SSM Session Manager enabled
- Only accessible from Web ALB security group

---

## Database Layer

### RDS Instance

| Property | Value |
|----------|-------|
| Engine | MySQL 8.0 |
| Instance Class | `db.t3.micro` |
| Storage | 20 GB (gp3, encrypted) |
| Multi-AZ | false (dev) / true (prod) |
| Subnets | 3 private subnets |
| Backup Retention | 7 days |
| Backup Window | 03:00–04:00 UTC |
| Maintenance Window | Monday 04:00–05:00 UTC |
| Deletion Protection | Disabled (dev) |
| Public Access | No |

### Credentials

- Master password generated by Terraform (`random_password`)
- Stored in AWS Secrets Manager at path: `{namespace}/{env}/db/credentials`
- Never stored in state file or code

---

## CI/CD Pipeline

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `bootstrap.yml` | Manual | Creates S3 state bucket (one-time) |
| `deploy.yml` | Manual | `plan` or `plan-and-apply` |
| `destroy.yml` | Manual | `plan` or `plan-and-destroy` |

### Authentication

GitHub Actions authenticates to AWS via **OIDC** — no static credentials stored in GitHub. The workflow assumes an IAM role scoped to this repository only.

### State Management

- **Backend:** S3 (`harsh-tf-state-ap-south-1`)
- **Locking:** S3 native locking (`use_lockfile = true`) — requires Terraform ≥ 1.10
- **Encryption:** AES-256 server-side encryption

---

## Security

### Network Security

| Control | Implementation |
|---------|---------------|
| Web instances | Accept HTTP only from Web ALB SG |
| App instances | Accept HTTP only from App ALB SG |
| RDS | Accept MySQL only from VPC CIDR |
| All instances | Egress unrestricted (for package installs via NAT) |
| Web ALB | Accept HTTP from `0.0.0.0/0` |
| App ALB | Accept HTTP from VPC CIDR only |

### Instance Security

- No SSH keys — access via SSM Session Manager only
- IAM role attached with `AmazonSSMManagedInstanceCore` policy
- Amazon Linux 2023 — security patches applied on launch via `dnf`

### Secrets Management

- DB credentials stored in AWS Secrets Manager
- No secrets in Terraform state (password marked `sensitive`)
- No AWS credentials in GitHub — OIDC only

---

## High Availability

| Layer | HA Mechanism |
|-------|-------------|
| Web | ALB across 3 AZs + ASG replaces unhealthy instances |
| App | Internal ALB across 3 AZs + ASG replaces unhealthy instances |
| Database | Multi-AZ enabled in prod (automatic failover to standby) |
| Network | Subnets in 3 AZs, single NAT Gateway (dev) |

> **Note:** Single NAT Gateway is a cost trade-off for dev. Production should use one NAT Gateway per AZ for full HA.

---

## Cost Optimization

See [cost-optimization.md](cost-optimization.md) for the full stakeholder document.

### Quick Reference

| Resource | Dev Monthly Est. | Optimization |
|----------|-----------------|--------------|
| EC2 (4x t3.micro) | ~$30 | Savings Plans or Reserved Instances for prod |
| RDS (db.t3.micro) | ~$25 | Reserved Instance saves ~40% |
| ALB (x2) | ~$35 | Combined ~$16 per ALB |
| NAT Gateway | ~$35 | Largest cost driver in dev |
| S3 (state) | <$1 | Negligible |
| **Total (est.)** | **~$125/month** | |
