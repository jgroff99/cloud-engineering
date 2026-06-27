# Week 9 Day 2 — Data Sources, Locals, and Expressions

## What This Config Does

Provisions an EC2 instance and S3 bucket using dynamic Terraform patterns — no hardcoded AMI IDs, no hardcoded CIDRs, no environment-specific values in the code itself.

**Resources created:**
- `aws_s3_bucket` — named `<project>-<environment>-<account_id>` for global uniqueness
- `aws_instance` — Amazon Linux 2, instance type selected dynamically by environment

**Data sources used:**
- `aws_caller_identity` — pulls the current AWS account ID at plan time
- `aws_ami` — fetches the latest Amazon Linux 2 AMI in the current region (no hardcoded AMI ID)

## Key Concepts Demonstrated

**Variables with validation** — type constraints and `validation` blocks reject bad inputs at plan time rather than letting them propagate to resource errors.

**Locals** — `name_prefix` and `common_tags` are computed from variables and reused across all resources. One change to `locals.tf` updates every resource consistently.

**`merge()` for tagging** — `common_tags` provides the base tag set; resource-specific tags like `Name` are merged in per resource. The second map wins on key conflict.

**`lookup()` for environment-aware sizing** — instance type is selected from a `map(string)` variable keyed by environment name, with a safe fallback default.

**`cidrsubnet()` for subnet math** — subnet CIDRs are calculated from `var.vpc_cidr` at plan time. Changing the parent CIDR recalculates all subnets automatically. Verified via outputs without creating real subnet resources.

**`terraform console`** — used to validate expressions interactively before committing them to config.

## Project Structure

```
Week-9/Day-2/
├── providers.tf              # AWS provider, version constraints
├── variables.tf              # Input variables with type constraints and validation
├── locals.tf                 # name_prefix, common_tags
├── data.tf                   # aws_caller_identity, aws_ami data sources
├── main.tf                   # S3 bucket and EC2 instance resources
├── outputs.tf                # vpc_id, instance info, subnet_cidrs preview
├── terraform.tfvars.example  # Variable template (commit this, not terraform.tfvars)
└── .gitignore                # Excludes *.tfstate, .terraform/, *.tfvars
```

## Prerequisites

- AWS CLI configured with credentials for `us-east-2`
- Terraform >= 1.0 installed

## Usage

```bash
# 1. Copy the example vars file and fill in your values
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Initialize
terraform init

# 3. Preview
terraform plan

# 4. Apply
terraform apply

# 5. Destroy when done (EC2 is billable)
terraform destroy
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_name` | `string` | — | Project name used in resource naming (max 20 chars) |
| `environment` | `string` | `"dev"` | Deployment environment: dev, staging, or prod |
| `aws_region` | `string` | `"us-east-2"` | AWS region to deploy into |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | Parent CIDR for subnet calculations |
| `instance_type_map` | `map(string)` | see below | Instance type per environment |

Default instance type map:
```hcl
{
  dev     = "t3.micro"
  staging = "t3.small"
  prod    = "t3.large"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `account_id` | Current AWS account ID (from data source) |
| `ami_id_used` | AMI ID selected by the aws_ami data source |
| `bucket_name` | Full name of the created S3 bucket |
| `instance_id` | EC2 instance ID |
| `instance_type_used` | Instance type selected for the current environment |
| `subnet_cidrs` | Calculated subnet CIDRs from cidrsubnet() — preview only, no subnets created |

## Decision Notes

**Why append account ID to the bucket name?** S3 bucket names are globally unique across all AWS accounts. Appending the account ID makes collisions between environments and teams structurally impossible without coordination.

**Why `lookup()` instead of a conditional?** A `map(string)` with `lookup()` scales cleanly to any number of environments. A conditional (`prod ? large : micro`) requires code changes to add a new environment; the map only requires a new key in `terraform.tfvars`.

**Why `aws_ami` data source instead of hardcoding?** AMI IDs are region-specific and get deprecated. A hardcoded ID breaks silently when moved to a new region or when the AMI is deprecated. The data source always resolves to the latest valid AMI for the current region.
