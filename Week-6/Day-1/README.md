# Week 6 Day 1 — VPC Fundamentals

## What I Built
A production-grade, multi-AZ VPC from scratch on AWS — the standard network architecture used in real production environments.

## Architecture

```
                        Internet
                           │
                    Internet Gateway
                    (prod-igw)
                           │
              ┌────────────┴────────────┐
              │                         │
     public-subnet-a          public-subnet-b
       10.0.1.0/24              10.0.2.0/24
          AZ-a                     AZ-b
              │
         NAT Gateway
         (prod-nat)
              │
    ┌─────────┴──────────┐
    │                    │
private-subnet-a   private-subnet-b
  10.0.3.0/24       10.0.4.0/24
     AZ-a               AZ-b
```

## Resources Created

| Resource | Name | Details |
|---|---|---|
| VPC | prod-vpc | 10.0.0.0/16 |
| Subnet | public-subnet-a | 10.0.1.0/24 — us-east-1a |
| Subnet | public-subnet-b | 10.0.2.0/24 — us-east-1b |
| Subnet | private-subnet-a | 10.0.3.0/24 — us-east-1a |
| Subnet | private-subnet-b | 10.0.4.0/24 — us-east-1b |
| Internet Gateway | prod-igw | Attached to prod-vpc |
| NAT Gateway | prod-nat | In public-subnet-a, with Elastic IP |
| Route Table | public-rt | 0.0.0.0/0 → IGW, associated with public subnets |
| Route Table | private-rt | 0.0.0.0/0 → NAT Gateway, associated with private subnets |
| Security Group | public-sg | Inbound SSH from my IP, ICMP from 10.0.0.0/16 |
| Security Group | private-sg | Inbound SSH and ICMP from 10.0.0.0/16 only |
| EC2 | public-instance | In public-subnet-a, public IP assigned |
| EC2 | private-instance | In private-subnet-a, no public IP |

## Route Tables

**public-rt** (associated with public-subnet-a and public-subnet-b):
```
Destination     Target
10.0.0.0/16  →  local
0.0.0.0/0    →  prod-igw
```

**private-rt** (associated with private-subnet-a and private-subnet-b):
```
Destination     Target
10.0.0.0/16  →  local
0.0.0.0/0    →  prod-nat
```

## What I Verified

- ✅ SSH into public instance directly from my machine
- ✅ Could NOT SSH directly into private instance from the internet (connection timed out — no route in)
- ✅ SSH'd into private instance via jump through public instance
- ✅ Pinged 8.8.8.8 from private instance — succeeded via NAT Gateway
- ✅ curl checkip.amazonaws.com from private instance returned NAT Gateway's Elastic IP, not the instance's private IP

## Key Concepts

**What makes a subnet public or private?**
Not a property of the subnet itself — determined entirely by its route table. A subnet is public if its route table has a `0.0.0.0/0 → IGW` route.

**Why does the NAT Gateway live in the public subnet?**
It needs internet access itself in order to forward outbound traffic from private instances. It bridges the private and public tiers.

**IGW vs NAT Gateway:**
- IGW is bidirectional — internet can initiate connections to public subnet instances
- NAT Gateway is outbound-only — private instances can reach out, but nothing can reach in

**Route table evaluation:**
Routes are matched most-specific first. `10.0.0.0/16` beats `0.0.0.0/0` for any VPC-internal traffic. `0.0.0.0/0` is the catch-all default route for everything else.

## Cost Notes
- NAT Gateway: ~$0.045/hr + data transfer — deleted immediately after lab
- Elastic IP: billed when allocated but not associated — released after NAT Gateway fully deleted
- EC2 instances: terminated after verification

## This Architecture Is The Foundation Of
- Week 8 project
- Every real production AWS environment
- Any multi-tier app (public load balancer → private app servers → private database)
