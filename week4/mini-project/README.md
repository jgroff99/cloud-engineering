# Week 4 Mini-Project: Auto-Scaling Web Server with Health Dashboard

## Overview
A production-pattern AWS architecture demonstrating EC2, ASG, ALB, Lambda, EventBridge, S3, IAM, and CloudWatch working together.

## Architecture
- **ALB** accepts HTTP traffic on port 80 and distributes it across healthy EC2 instances
- **ASG** maintains a minimum of 2 EC2 instances across us-east-2a and us-east-2b, scaling up to 4 based on CPU utilization (target 50%)
- **EC2 instances** run Apache via a User Data bootstrap script, each serving a page displaying their own hostname — making load balancing visible
- **Lambda** (Python 3.12) runs every 5 minutes triggered by EventBridge, calls `describe_target_health` on the ALB target group, and writes a timestamped JSON health report to S3
- **S3** stores the health reports at `health-reports/YYYY-MM-DD_HH-MM-SS.json`
- **IAM role** (`lambda-alb-health-role`) grants Lambda permissions for CloudWatch Logs, S3 writes, and ELB describe actions

## Services Used
| Service | Purpose |
|---|---|
| EC2 | Web server instances |
| AMI | Amazon Linux 2023 with Apache |
| ASG | Auto-scaling across 2 AZs |
| ALB | Load balancing + health checks |
| Lambda | Scheduled health checker |
| EventBridge | 5-minute schedule trigger |
| S3 | Health report storage |
| IAM | Least-privilege roles |
| CloudWatch | Scaling alarms + Lambda logs |

## Key Concepts Demonstrated
- Security group chaining (ALB SG as source for EC2 SG)
- ELB health checks driving ASG instance replacement
- Target tracking scaling policy (scale in observed during low traffic)
- Serverless scheduled tasks with EventBridge
- IAM roles for service-to-service permissions

## Region
`us-east-2` (Ohio)

## Lambda Deployment
```bash
cd lambda-health-checker
zip function.zip lambda_function.py
aws lambda update-function-code \
  --function-name alb-health-checker \
  --zip-file fileb://function.zip \
  --region us-east-2
```
