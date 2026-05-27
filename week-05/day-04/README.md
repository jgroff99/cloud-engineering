# Week 5 Day 4 — RDS: Relational Databases in AWS

## What I built

A two-tier architecture connecting an EC2 application server to a managed MySQL RDS database over a private network — the most common backend architecture pattern in AWS.

**Architecture:**
- VPC with public and private subnets across 2 AZs
- EC2 (t3.micro, Ubuntu) in the public subnet — app tier
- RDS MySQL (db.t3.micro) in the private subnet — data tier
- No public access on RDS — only reachable from inside the VPC

## Key concepts learned

### RDS vs. self-managed database on EC2
RDS is managed SQL — AWS handles backups, patching, failover, and replication. You only manage the data. The rule of thumb: always use RDS unless you need OS-level access or a specific feature RDS doesn't support.

### Supported engines
MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Amazon Aurora (AWS-native, MySQL/PostgreSQL-compatible, up to 5x faster, storage auto-scales to 128 TB).

### Multi-AZ vs. Read Replicas

| | Multi-AZ | Read Replicas |
|---|---|---|
| Purpose | Survive failure | Handle more reads |
| Readable? | No | Yes |
| Replication | Synchronous | Asynchronous |
| Failover | Automatic (~60s) | Manual promotion |

**One-liner:** Multi-AZ keeps you alive, read replicas keep you fast.

### Backup strategies
- **Automated backups** — daily snapshots + transaction logs, retained 1–35 days, deleted when instance is deleted
- **Manual snapshots** — user-initiated, kept until you explicitly delete them, survive instance deletion

## Lab commands

### Install MySQL client on EC2
```bash
sudo apt update && sudo apt install mysql-client -y
```

### Connect to RDS from EC2
```bash
mysql -h YOUR-RDS-ENDPOINT -u admin -p
```

### SQL run during the lab
```sql
CREATE DATABASE myapp;
USE myapp;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Charlie');

SELECT * FROM users;
```

## Networking setup

| Resource | Config |
|---|---|
| VPC CIDR | 10.0.0.0/16 |
| Public subnet 1 | 10.0.0.0/24 (AZ a) — EC2 here |
| Public subnet 2 | 10.0.1.0/24 (AZ b) |
| Private subnet 1 | 10.0.2.0/24 (AZ a) — RDS here |
| Private subnet 2 | 10.0.3.0/24 (AZ b) — required for DB subnet group |
| NAT gateway | None — not needed for this lab |

### Security groups
- **ec2-sg** — inbound SSH (port 22) from my IP only
- **rds-sg** — inbound MySQL (port 3306) from ec2-sg only

The RDS security group references the EC2 security group ID as its source — not an IP address. This means only traffic originating from the EC2 instance is allowed in, regardless of what IP it's on.

## Cost notes
- VPC, subnets, internet gateway, route tables — free
- EC2 t3.micro — free tier (stop when not in use)
- RDS db.t3.micro — free tier, but **charges by the hour even when idle**

RDS instance deleted after lab. Final snapshot saved as `week5-day4-final` for restore in Week 8 project.

## Architecture pattern
This EC2 → RDS private subnet pattern is the foundation of the Week 8 portfolio project. The app tier (EC2) lives in a public subnet and is reachable from the internet. The data tier (RDS) lives in a private subnet and is only reachable from the app tier. Nothing in the data tier has a public IP.
