# Week 9, Day 3 — Terraform VPC

Provisions a complete, production-pattern VPC using Terraform. The same network that took 3 hours to build manually in Week 6 now deploys in ~90 seconds and destroys cleanly with a single command.

## Architecture

```
Internet
    │
    ▼
Internet Gateway
    │
    ├── public-a (10.0.1.0/24)  us-east-2a  ← NAT Gateway + EIP
    └── public-b (10.0.2.0/24)  us-east-2b

    NAT Gateway
    │
    ├── private-a (10.0.11.0/24)  us-east-2a
    └── private-b (10.0.12.0/24)  us-east-2b
```

**Resources provisioned (14 total):**
- 1 VPC with DNS support and hostnames enabled
- 4 subnets across 2 AZs (2 public, 2 private)
- 1 Internet Gateway
- 1 Elastic IP + 1 NAT Gateway (in public-a)
- 2 route tables (public → IGW, private → NAT)
- 4 route table associations

## Key Terraform Concepts Demonstrated

### `for_each` over a variable map
All four subnets are created from a single `aws_subnet` resource block. The map key (`"public-a"`, `"private-b"`, etc.) becomes the stable state identifier — adding or removing a subnet only touches that one resource, with no cascade destroy of the others.

```hcl
resource "aws_subnet" "this" {
  for_each = var.subnets
  vpc_id   = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  ...
}
```

### `cidrsubnet()` for dynamic CIDR calculation
Subnet CIDRs are calculated mathematically from the parent VPC CIDR — no hardcoded IP addresses anywhere in the config. Changing `vpc_cidr` recalculates all four subnets automatically.

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)  # → 10.0.1.0/24  (public-a)
cidrsubnet("10.0.0.0/16", 8, 11) # → 10.0.11.0/24 (private-a)
```

### `locals` for map filtering
`locals.tf` splits the full subnet map into `public_subnets` and `private_subnets` using a `for` expression. Route table associations then iterate over the appropriate sub-map — no hardcoding of which subnets belong to which tier.

```hcl
locals {
  public_subnets  = { for k, v in var.subnets : k => v if v.public }
  private_subnets = { for k, v in var.subnets : k => v if !v.public }
}
```

### Data source for AZ discovery
`data.aws_availability_zones.available` queries AWS at plan time for available AZs in the configured region. No hardcoded `us-east-2a` strings — the config works in any region.

### Implicit dependency chain
Terraform infers creation order entirely from attribute references. The dependency chain `VPC → subnets → NAT Gateway → private route table → private associations` requires no `depends_on` except one: the NAT Gateway depends on the IGW being attached to the VPC, but doesn't reference the IGW's attributes directly — that single explicit edge is the only manual hint in the config.

## File Structure

```
Week-9/Day-3/
├── providers.tf      # AWS provider, version constraints
├── variables.tf      # Input variables with type constraints and validation
├── locals.tf         # name_prefix, common_tags, public/private subnet maps
├── data.tf           # data.aws_availability_zones.available
├── main.tf           # All 14 resources
├── outputs.tf        # vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_id
└── terraform.tfvars  # project, environment, vpc_cidr (gitignored)
```

## Usage

```bash
terraform init
terraform plan
terraform apply

# Destroy when done (NAT Gateway bills hourly)
terraform destroy
```

## Design Decisions

**`netnum` spacing (1, 2, 11, 12 instead of 0, 1, 2, 3):** Leaves gaps in the CIDR space so future subnets can be added without shifting existing `netnum` values. Shifting a `netnum` changes the CIDR, which forces a destroy-and-recreate of that subnet and anything in it.

**NAT Gateway in public-a only:** A single NAT Gateway is sufficient for a dev environment. Production would run one per AZ for fault isolation — each private subnet would route through the NAT Gateway in its own AZ, eliminating cross-AZ traffic costs during an AZ failure.

**`depends_on` on the NAT Gateway:** The NAT Gateway needs the Internet Gateway attached before it can provision, but references only the subnet and EIP — not the IGW directly. Without `depends_on = [aws_internet_gateway.main]`, Terraform cannot infer this edge and may attempt to create the NAT Gateway before the IGW is attached, causing a provisioning error.

**This config becomes the networking module in Week 12.**
