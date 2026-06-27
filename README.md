# Week 6 Mini-Project: Multi-Tier VPC Architecture with CDN

## Architecture Overview

A production-grade multi-tier AWS architecture combining CloudFront, S3, ALB, and EC2
across public and private subnets, with private DNS resolution via Route 53.
Internet

│

▼

┌─────────────────────────────────────────┐

│           CloudFront Distribution        │

│         d351k286pakii0.cloudfront.net   │

│                                         │

│  Default behavior: /* → S3 (OAC)        │

│  API behavior: /api/* → ALB (no cache)  │

└────────────┬────────────────┬───────────┘

│                │

▼                ▼

┌────────────────┐   ┌─────────────────────┐

│   S3 Bucket    │   │  Application LB     │

│ ce-week6-      │   │  week6-alb          │

│ frontend-      │   │  (public subnets)   │

│ jgroff99       │   │  sg: alb-sg         │

│                │   │  port 80 → TG       │

│ Block public   │   └─────────┬───────────┘

│ access: ON     │             │

│ OAC signed     │    alb-sg allows port 80

│ requests only  │    into app-sg

└────────────────┘             │

┌──────────┴──────────┐

│                     │

┌─────────▼──────┐   ┌──────────▼─────┐

│ EC2: app-1     │   │ EC2: app-2     │

│ us-east-2a     │   │ us-east-2b     │

│ private subnet │   │ private subnet │

│ sg: app-sg     │   │ sg: app-sg     │

│ 10.0.140.233   │   │ 10.0.156.154   │

└────────────────┘   └────────────────┘
Private DNS (Route 53 - myapp.internal):

db.internal.myapp.internal → 10.0.1.100 (placeholder RDS)
## Resources

| Resource | ID / Value |
|---|---|
| VPC | vpc-00d5f3d052d731c73 (10.0.0.0/16) |
| Public Subnet 1 | subnet-076c17e606217715c (us-east-2a) |
| Public Subnet 2 | subnet-0bd7a2376d93a8317 (us-east-2b) |
| Private Subnet 1 | subnet-073da33c530a28ba2 (us-east-2a) |
| Private Subnet 2 | subnet-088fe0540a3fe4b78 (us-east-2b) |
| ALB SG | sg-085af72b9a13eed84 |
| App SG | sg-0a99794257adcc621 |
| CloudFront | E1A3GFU1RJCS3K |
| S3 Bucket | ce-week6-frontend-jgroff99 |
| OAC | EH2HGUP7RN079 |
| Private Hosted Zone | Z01422291ARPIFO06BF8N (myapp.internal) |

## Design Decisions

### CloudFront as the single entry point
All traffic enters through CloudFront — users never interact with S3 or the ALB directly.
This provides a single security boundary, unified HTTPS termination, and global edge caching.

### S3 with OAC (not public)
The S3 bucket has all public access blocked. CloudFront uses Origin Access Control (OAC)
with SigV4-signed requests and a bucket policy scoped to this specific distribution ARN.
Direct S3 URL access returns 403. OAC is the current AWS best practice, replacing the
older Origin Access Identity (OAI) pattern.

### Cache behavior split: /* vs /api/*
Static assets (HTML, CSS, JS) are served from S3 with caching enabled — CloudFront
caches them at edge locations globally (CachingOptimized policy). API requests (/api/*)
bypass the cache entirely (CachingDisabled policy) and pass through to the ALB, ensuring
responses are always fresh from the application tier.

### SG chaining: alb-sg → app-sg
EC2 instances in private subnets accept port 80 only from alb-sg (not from 0.0.0.0/0).
This means even if an attacker reached the private subnet, they couldn't directly hit
the app servers without coming through the ALB. The ALB itself accepts port 80/443 from
0.0.0.0/0 (CloudFront), but in production this would be locked to CloudFront managed
prefix lists only.

### Private subnets for compute
EC2 instances have no public IPs and no route to the internet gateway. They are
unreachable from the internet by design — all inbound traffic flows through the ALB,
all outbound traffic (for package updates) would flow through a NAT Gateway (not
deployed here to avoid cost; add one in production).

### Private Route 53 hosted zone
Internal services resolve via myapp.internal — only resolvable within the VPC.
db.internal.myapp.internal → 10.0.1.100 simulates RDS endpoint resolution.
In production this record would point to an RDS endpoint, decoupling application
config from the underlying database hostname.

### Route 53 Alias → CloudFront (production pattern)
This lab uses the default CloudFront domain (d351k286pakii0.cloudfront.net) because
a registered domain is required for Route 53 public hosted zones. In production:
- Register a domain via Route 53 (~$3/year for .click)
- Create a public hosted zone
- Add an Alias record: example.com → CloudFront distribution
- Alias records work at the zone apex (root domain), which CNAMEs cannot

## Traffic Flow

### Static asset request (GET /index.html)
1. User → CloudFront edge (SEA900 — Seattle)
2. Cache miss on first request → CloudFront fetches from S3 using OAC SigV4 signature
3. S3 validates signature against bucket policy → returns object
4. CloudFront caches object at edge, returns to user
5. Subsequent requests → Cache Hit, served from edge (sub-millisecond)

### API request (GET /api/health)
1. User → CloudFront edge
2. Path matches /api/* behavior → CachingDisabled → forwards to ALB origin
3. ALB receives request, evaluates listener rule → forwards to week6-app-tg
4. Target group selects healthy instance (round-robin across us-east-2a and us-east-2b)
5. Request passes through alb-sg → app-sg chain → reaches EC2
6. EC2 returns JSON response → ALB → CloudFront → User

## Verified Outputs

CloudFront cache behavior confirmed:
- First request: x-cache: Miss from cloudfront
- Second request: x-cache: Hit from cloudfront

ALB load balancing confirmed across 5 requests:
- us-east-2a (ip-10-0-140-233) and us-east-2b (ip-10-0-156-154) alternating evenly

## Cleanup

```bash
# CloudFront (disable first, then delete)
aws cloudfront get-distribution-config --id E1A3GFU1RJCS3K
# Set Enabled: false, update, then delete

# ALB and target group
aws elbv2 delete-listener --listener-arn <listener-arn>
aws elbv2 delete-load-balancer --load-balancer-arn <alb-arn>
aws elbv2 delete-target-group --target-group-arn <tg-arn>

# EC2 instances
aws ec2 terminate-instances --instance-ids i-0812037e3ca83bbad i-07fc06f30a39e6a43

# Route 53
aws route53 delete-hosted-zone --id Z01422291ARPIFO06BF8N

# S3
aws s3 rm s3://ce-week6-frontend-jgroff99 --recursive
aws s3 rb s3://ce-week6-frontend-jgroff99

# OAC
aws cloudfront delete-origin-access-control --id EH2HGUP7RN079
```
