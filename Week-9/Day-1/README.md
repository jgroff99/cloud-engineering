# Week 9 — Day 1: Terraform Fundamentals

## What I Built

A basic Terraform configuration that provisions an S3 bucket on AWS using Infrastructure as Code. The configuration demonstrates the core IaC workflow — writing declarative HCL, initializing a provider, planning changes before applying them, modifying existing infrastructure in place, and tearing it all down cleanly. This is the foundation for all Terraform work in Phase 3.

## File Structure

| File | Purpose |
|------|---------|
| `providers.tf` | Pins the AWS provider to the 5.x line and sets the deployment region |
| `variables.tf` | Declares input variables (bucket name) to avoid hardcoded values |
| `main.tf` | Defines the S3 bucket resource with tags |
| `outputs.tf` | Exposes the bucket ARN and bucket name after apply |

## Terraform Workflow

| Command | What it does |
|---------|-------------|
| `terraform init` | Downloads the provider plugin and initializes the working directory |
| `terraform fmt` | Auto-formats all `.tf` files to the canonical HCL style |
| `terraform validate` | Checks syntax and resource references without hitting AWS |
| `terraform plan` | Shows exactly what will be created, modified, or destroyed — read this before every apply |
| `terraform apply` | Executes the plan and creates/modifies real infrastructure in AWS |
| `terraform destroy` | Tears down all resources managed by this configuration |

## Terraform State

After `terraform apply`, Terraform writes a `terraform.tfstate` file that maps every resource block to its real AWS resource ID. This is how Terraform tracks what it has created and plans future changes.

State files are excluded from Git for two reasons:
1. They can contain sensitive values (passwords, keys) passed as resource arguments
2. They are not source code — they represent current reality, not desired state

The `.terraform.lock.hcl` file is committed because it pins exact provider versions, ensuring consistent behavior across machines and teammates.

## Key Concepts

**Declarative IaC** — You describe the desired end state; Terraform figures out how to get there and in what order.

**Plan symbols** — `+` create, `~` modify in place, `-` destroy, `-/+` destroy and recreate. Always read the plan summary (`X to add, X to change, X to destroy`) before typing `yes`.

**Resource references** — Attributes of one resource are referenced in another using `resource_type.local_name.attribute` (e.g. `aws_s3_bucket.my_bucket.arn`). Terraform uses these references to build a dependency graph and determine creation order automatically.
