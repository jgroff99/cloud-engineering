# Week 7 Day 2 — IAM Roles & STS

## Objective
Understand how IAM roles work, how STS issues temporary credentials, and see the mechanism live from inside an EC2 instance and from a local machine.

---

## Concepts Covered

### IAM Roles vs Users
- An IAM **user** has permanent credentials (access key + secret)
- An IAM **role** has no permanent credentials — STS issues temporary ones on each assumption
- Temporary credentials consist of: `AccessKeyId`, `SecretAccessKey`, `SessionToken`
- All three expire together (default 1 hour, max 12 hours)

### The Two Policies on Every Role
| Policy | Purpose |
|---|---|
| Trust Policy | WHO can assume this role (`sts:AssumeRole`) |
| Permissions Policy | WHAT you can do after assuming it |

### EC2 Instance Profile
The instance profile is a wrapper object that bridges an IAM role to an EC2 instance. EC2 cannot attach a role directly.

**CLI creation order (role → policy → profile → link → attach):**
1. Create the IAM role with a trust policy allowing `ec2.amazonaws.com`
2. Attach a permissions policy to the role
3. Create the instance profile
4. Add the role to the instance profile
5. Attach the instance profile to the EC2 instance at launch

**Runtime flow:**
1. EC2 service automatically calls `sts:AssumeRole`
2. STS issues temporary credentials
3. Credentials are placed at the metadata endpoint: `http://169.254.169.254/latest/meta-data/iam/security-credentials/<role-name>`
4. AWS CLI/SDK checks this endpoint automatically — no credentials needed in code

### IMDSv2
New EC2 instances enforce IMDSv2 (token-required). Raw curl calls to the metadata endpoint require a token:
```bash
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/<role-name>
```
The AWS CLI handles IMDSv2 automatically.

### Temporary Credential Prefixes
- `AKIA...` — long-term access key (IAM user)
- `ASIA...` — temporary credential issued by STS

---

## Lab

### Resources Created
- S3 bucket: `jordan-iam-lab-2024` with `test.txt`
- IAM role: `EC2-S3-ReadRole`
- IAM policy: `S3-IAMLab-ReadPolicy` (s3:GetObject + s3:ListBucket on the lab bucket)
- Instance profile: `EC2-S3-ReadProfile`
- EC2 instance: `iam-lab-instance` (t3.micro, us-east-2)

### Phase 1 — EC2 Instance Profile Verification
SSHed into the instance and confirmed:
- `aws configure list` showed credentials sourced from `iam-role` type, region from `imds`
- Metadata endpoint returned the role name and full temporary credentials JSON
- `aws s3 ls s3://jordan-iam-lab-2024` succeeded with no credentials configured

### Phase 2 — Manual Role Assumption from Local Machine
```bash
aws sts assume-role \
  --role-arn arn:aws:iam::455919270027:role/EC2-S3-ReadRole \
  --role-session-name manual-test-session
```
- Exported returned credentials as environment variables
- `aws sts get-caller-identity` confirmed identity switched to `assumed-role/EC2-S3-ReadRole/manual-test-session`
- `aws s3 ls s3://jordan-iam-lab-2024` succeeded
- `aws s3 ls` (list all buckets) returned `AccessDenied` — role scoped to one bucket only
- Unset env vars to return to admin user

### Key Observations
- Trust policy blocked the initial assume-role attempt from the admin user — being an admin doesn't automatically grant assume-role on every role
- The session name (`manual-test-session`) appears in the ARN and CloudTrail — critical for audit trails
- Assumed role credentials are constrained to the role's permissions policy regardless of the caller's own permissions

---

## Cleanup
All resources terminated and deleted after the lab.

---

## Files
| File | Purpose |
|---|---|
| `trust-policy.json` | Initial trust policy — EC2 service only |
| `trust-policy-updated.json` | Updated trust policy — EC2 service + admin IAM user |
| `s3-read-policy.json` | Permissions policy — s3:GetObject + s3:ListBucket on lab bucket |
