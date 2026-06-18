# Week 8 Day 4 — Application Tier & Load Balancer

## What was built
Full application tier for the 3-tier capstone architecture:
- IAM role and instance profile with least-privilege permissions
- Launch Template with User Data bootstrap script
- Auto Scaling Group across two private subnets (min=1, max=3, desired=2)
- Target tracking scaling policy at 60% CPU
- Application Load Balancer in public subnets
- Target group with /health check on port 5000
- Flask app fetching credentials from Secrets Manager at runtime

## Architecture
Internet → ALB (public subnets, port 80)

→ Target Group → EC2 ASG (private subnets, port 5000)

→ Secrets Manager (via IAM role + NAT Gateway)
## Resources created
| Resource | ID/ARN |
|---|---|
| IAM Role | week8-app-role |
| IAM Policy | week8-app-policy |
| Instance Profile | week8-app-instance-profile |
| Launch Template | lt-012e221d1ce5e39be |
| Auto Scaling Group | week8-app-asg |
| Scaling Policy | week8-cpu-tracking (60% CPU target tracking) |
| ALB | week8-alb |
| ALB DNS | week8-alb-1834531349.us-east-2.elb.amazonaws.com |
| Target Group | week8-app-tg (port 5000) |
| Listener | HTTP:80 → week8-app-tg |

## Key lessons
- Security group for app tier must allow the actual application port (5000),
  not just port 80 — missing this caused Target.Timeout on health checks
- When switching ASG health check type to ELB, instances that are currently
  unhealthy will be terminated and replaced — timing matters
- User Data logging (set -e + exec tee pipeline) makes bootstrap debugging
  straightforward: cat /var/log/user-data.log shows exactly where failures occur
- nohup + & required to keep Flask running after User Data script exits
- /health endpoint must be dependency-free — never put DB calls in health checks

## Endpoints verified
- / → 200, application tier confirmed live
- /health → 200, ALB health check passing
- /dbcheck → credentials_retrieved, IAM role + Secrets Manager working
