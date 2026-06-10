# Week 7 Day 3 — Cross-Account Access Lab

## Architecture
- lab-user-a: simulates identity account principal, no direct S3 permissions
- CrossAccountReadRole: trust policy allows lab-user-a to assume it, permissions policy allows S3 read on crossaccount-lab bucket
- crossaccount-lab-<account-id>: protected resource only accessible via role assumption

## Pattern proven
1. lab-user-a direct S3 access → AccessDenied (no identity-based policy)
2. lab-user-a assumes CrossAccountReadRole via sts:AssumeRole
3. Export AccessKeyId + SecretAccessKey + SessionToken as env vars
4. CLI identity becomes assumed-role/CrossAccountReadRole/cross-account-lab-session
5. S3 ListBucket and GetObject succeed

## Key mechanics
- Both sides must allow: trust policy (Account B) + sts:AssumeRole permission (Account A)
- Temporary credentials have three components — all three required (session token is mandatory)
- Unset env vars to return to default profile credentials
- CloudTrail logs show assumed-role ARN with session name for auditability

## Real multi-account difference
- Principal ARN in trust policy would reference a different account ID
- Mechanism is identical — only the account ID in the ARN changes
