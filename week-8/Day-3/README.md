# Week 8 Day 3 — Capstone Project: Networking and Data Tier

## Objectives
- Build a fresh VPC with public/private subnet architecture for the capstone project
- Create all security groups upfront using least-privilege rules
- Deploy an encrypted RDS MySQL instance in private subnets with Multi-AZ
- Store database credentials in Secrets Manager
- Verify database connectivity via bastion host

## Architecture

### VPC
- **VPC**: vpc-0fb862de5b5099a84 (10.0.0.0/16)
- **Public Subnet A**: 10.0.1.0/24 — us-east-2a
- **Public Subnet B**: 10.0.2.0/24 — us-east-2b
- **Private Subnet A**: 10.0.3.0/24 — us-east-2a
- **Private Subnet B**: 10.0.4.0/24 — us-east-2b
- **Internet Gateway**: igw-099386ffcac210748
- **NAT Gateway**: nat-02a5130d18c8a7886 (in Public Subnet A)

### Routing
- Public route table: 0.0.0.0/0 → IGW (associated with both public subnets)
- Private route table: 0.0.0.0/0 → NAT Gateway (associated with both private subnets)

### Security Groups
| Name | Inbound Rule |
|------|-------------|
| week8-alb-sg | 80, 443 from 0.0.0.0/0 |
| week8-app-sg | 80 from alb-sg only |
| week8-db-sg | 3306 from app-sg and bastion-sg |
| week8-bastion-sg | 22 from my IP only |

### Database Tier
- **Engine**: MySQL 8.0.45
- **Instance**: db.t3.micro
- **Subnets**: Private subnets (us-east-2a, us-east-2b)
- **Multi-AZ**: Enabled (standby replica in us-east-2b)
- **Encryption**: Enabled via KMS CMK (alias/week8-rds-key)
- **Endpoint**: week8-mysql.cvueaqswe364.us-east-2.rds.amazonaws.com
- **Credentials**: Stored in Secrets Manager (week8/mysql/credentials)
- **Public Access**: Disabled

## Key Concepts

### Why a fresh VPC?
Each project gets its own isolated network boundary. Reusing lab VPCs creates dependency and naming conflicts — a production project should be self-contained.

### Public vs private subnets
Public and private are not intrinsic AWS properties. A subnet becomes public by routing to an IGW, and private by routing through a NAT Gateway. The NAT Gateway allows private resources to make outbound internet calls (e.g. software updates) without being reachable from the internet.

### Security group chaining
The ALB → App → DB chain enforces least privilege at each tier. The DB accepts traffic only from the app tier security group, not from any IP range — even within the VPC. This means a compromised resource outside the app tier cannot reach the database.

### Why Secrets Manager over hardcoding?
Credentials stored in Secrets Manager are never in code or config files. Applications retrieve them at runtime via API call, enabling rotation without redeployment.

### Multi-AZ RDS
Multi-AZ provisions a synchronous standby replica in a second AZ. Failover is automatic — AWS promotes the standby if the primary becomes unavailable. RTO is typically 1-2 minutes.

## Connectivity Verification
- Launched bastion host in Public Subnet A (week8-bastion-sg)
- SSH'd to bastion via public IP
- Connected to RDS endpoint on port 3306 using MySQL client
- Verified 4 default system databases present

## Resources Created
| Resource | ID |
|----------|-----|
| VPC | vpc-0fb862de5b5099a84 |
| Public Subnet A | subnet-021b82464cd87d5a8 |
| Public Subnet B | subnet-070d02610ae9a6990 |
| Private Subnet A | subnet-0a63187ea6a3e066c |
| Private Subnet B | subnet-07aac332eb04dbc44 |
| Internet Gateway | igw-099386ffcac210748 |
| NAT Gateway | nat-02a5130d18c8a7886 |
| ALB SG | sg-02dbb9c19f4dfce3d |
| App SG | sg-038632cdc9c3bfac5 |
| DB SG | sg-07eed314dbf2f3513 |
| Bastion SG | sg-081ba84485304d5ce |
| RDS Instance | week8-mysql |
| KMS Key | alias/week8-rds-key |
| Secrets Manager | week8/mysql/credentials |
| Bastion Host | i-09ce7287d9ad3febf |

## Day 4 Preview
- Launch EC2 instances in private subnets (app tier)
- Create Application Load Balancer in public subnets
- Configure ALB target group and listener
- Deploy sample application and verify end-to-end traffic flow
