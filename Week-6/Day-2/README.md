# Week 6 Day 2 — Security Groups and NACLs

## Overview
Built and verified a multi-tier security architecture in AWS using Security Group chaining and Network ACLs. Demonstrated layered network security across three tiers: ALB, application, and database.

## Architecture
Internet
↓
alb-sg (port 80/443 from 0.0.0.0/0)
↓
app-sg (port 80 from alb-sg only)
↓
db-sg (port 3306 from app-sg only)
## Security Groups

### alb-sg
| Direction | Port | Source | Purpose |
|-----------|------|--------|---------|
| Inbound | 80 | 0.0.0.0/0 | Public HTTP traffic |
| Inbound | 443 | 0.0.0.0/0 | Public HTTPS traffic |
| Inbound | 22 | My IP | SSH management |

### app-sg
| Direction | Port | Source | Purpose |
|-----------|------|--------|---------|
| Inbound | 80 | alb-sg | Traffic from ALB only |
| Inbound | 22 | alb-sg | SSH via jump box only |

### db-sg
| Direction | Port | Source | Purpose |
|-----------|------|--------|---------|
| Inbound | 3306 | app-sg | MySQL from app tier only |

## NACL Configuration (lab exercise — removed after verification)
- Attached to private subnet
- Rule 50: DENY all traffic from alb-instance private IP
- Rule 100: ALLOW all traffic
- Verified NACL deny overrides SG allow rules

## Key Concepts Learned

### Security Group chaining
SGs reference other SGs as sources rather than IP ranges. This means:
- Access is identity-based, not IP-based
- Rules stay valid as instances scale or get replaced
- No manual IP list maintenance

### SG vs NACL
| Property | Security Group | NACL |
|----------|---------------|------|
| Level | Resource (ENI) | Subnet |
| Stateful | Yes | No |
| Deny rules | No | Yes |
| Rule order | All evaluated | First match wins |

### Stateless NACL gotcha
NACLs require explicit outbound rules for ephemeral return ports (1024-65535). Forgetting this allows inbound traffic but silently drops all responses.

## Verification Results
- alb-instance → internet on port 80/443 ✅
- app-instance → alb-instance on port 80 ✅
- app-instance unreachable directly from internet ✅
- db-instance → app-instance on port 3306 ✅
- db-instance unreachable from alb-instance on port 3306 ✅
- NACL deny overrode SG allow rule ✅

## Resources
- VPC: week-6-vpc (10.0.0.0/16)
- Public subnet: alb-instance (Amazon Linux 2, t2.micro)
- Private subnet: app-instance (Amazon Linux 2, t2.micro)
- Private subnet: db-instance (Amazon Linux 2, t2.micro)
