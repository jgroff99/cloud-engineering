# Week 7 Day 5 — Secrets Manager, IAM Identity Center, Security Monitoring

## What I built
- Stored RDS credentials in Secrets Manager as `prod/rds/mysql`
- Python script (`fetch_secret.py`) that fetches credentials at runtime via boto3 — no hardcoded values
- Configured Secrets Manager automatic rotation (30-day schedule, single-user strategy, Lambda rotation function)
- Created CloudTrail trail writing to S3 for long-term log retention
- Investigated real CloudTrail events via CLI using `lookup-events`

## Key commands
```bash
# Fetch a secret at runtime
aws secretsmanager get-secret-value --secret-id "prod/rds/mysql" --region us-east-2

# Trigger immediate rotation
aws secretsmanager rotate-secret --secret-id "prod/rds/mysql" --rotate-immediately --region us-east-2

# Investigate events by name
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteUser

# Investigate all actions by a user
aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=admin
```

## Lessons learned
- Secrets Manager rotation Lambda needs network access to both RDS (port 3306) and Secrets Manager endpoint
- IAM events have higher propagation delay in regional CloudTrail trails (~15-20 min) vs regional service events
- CloudTrail captures full forensic detail: who, when, from where, exact parameters
- For broad forensic queries, Athena on S3 logs is faster than lookup-events
- Console-created rotation functions handle VPC/IAM wiring better than manual CLI setup

## Security monitoring stack
- CloudTrail — audit log of every API call (always enable)
- GuardDuty — ML threat detection (~$1-3/month for small accounts)
- Security Hub — aggregates findings, runs compliance checks
