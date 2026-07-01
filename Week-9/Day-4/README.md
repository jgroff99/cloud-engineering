# Week 9, Day 4 — Extending VPC Config: EC2, Security Groups, IAM

## Overview
This lab extends the Day 3 VPC/networking config with a compute layer — security
groups, an IAM role for EC2, a Launch Template, and EC2 instances — without touching
the existing networking resources. Goal: the AWS console reflects exactly what the
`.tf` files declare, with code as the single source of truth for both layers.

## What Was Added
- **Security group** with ingress rules built via `for_each` over a rules map (no
  copy-pasted resource blocks per rule) and an all-outbound egress rule
- **IAM role + instance profile** for EC2, with the AWS-managed SSM policy attached
  (`AmazonSSMManagedInstanceCore`) — enables Session Manager access with no SSH key
  pair required
- **Launch Template** referencing the `data.aws_ami.amazon_linux_2023` source
  (originally looked up in Day 2/3), with user data rendered via `templatefile()`
  from `templates/user_data.tftpl`
- **Two EC2 instances**, one per private subnet, provisioned via `for_each` over the
  private subnets map
- **`prevent_destroy = true`** added to the `aws_vpc.main` resource, to guard the
  networking layer against accidental destruction while the compute layer was being
  built on top of it

## Why This Pattern
- `for_each` over a security group rules map avoids near-duplicate resource blocks
  for each ingress rule — adding a new rule means adding a map entry, not writing a
  new resource.
- IAM role + SSM policy instead of a key pair removes SSH exposure entirely — no
  inbound port 22, no key management, no bastion host needed for instance access.
- `templatefile()` keeps user data logic out of `main.tf` and lets the same script
  template be reused with different variable values per environment.
- `prevent_destroy` on the VPC is a safety rail: once compute resources depend on the
  network layer, an accidental `destroy` of the VPC would cascade and take everything
  with it. This lifecycle rule made `terraform destroy` refuse to proceed against the
  VPC until deliberately removed — which is what happened before the full teardown of
  this lab's resources (see Day 5 for that change).

## Verification
`terraform plan` after adding the compute layer showed zero changes to the existing
VPC, subnets, route tables, or IGW from Day 3 — confirming the extension didn't drift
or recreate any networking resources.

## Files
- `providers.tf` — provider version pin
- `variables.tf` / `locals.tf` / `data.tf` — inputs, computed values, AZ/AMI lookups
- `main.tf` — VPC, subnets, IGW, route tables, security group, IAM role/profile,
  Launch Template, EC2 instances
- `outputs.tf` — VPC ID, subnet ID maps, NAT Gateway ID, instance private IPs/IDs
- `templates/user_data.tftpl` — EC2 user data script template

## Note
This config was fully torn down via `terraform destroy` after the lab (the
`prevent_destroy` rule was removed first — see the Day 5 commit). No infrastructure
from this lab is currently running.
