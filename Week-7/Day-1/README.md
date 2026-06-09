# Week 7 Day 1 — IAM Deep Dive: Policies, Roles, and Evaluation Logic

## What I Learned
A deep dive into IAM policy types, JSON policy structure, condition keys, and the evaluation logic AWS uses to determine allow or deny on every API call.

---

## IAM Policy Types

### 1. Identity-based Policies
Attached to IAM users, groups, or roles. Answer: *"What can this identity do?"*
- **Inline policies** — embedded directly into a single identity
- **Managed policies** — standalone, reusable, attachable to multiple identities

### 2. Resource-based Policies
Attached directly to a resource (S3 bucket, KMS key, SQS queue, Lambda, etc.). Answer: *"Who can access this resource?"*
- Always inline — no managed resource-based policies
- Can grant cross-account access without role assumption

### 3. Permission Boundaries
A managed policy attached to a role or user that sets the **maximum permissions ceiling**.
- Identity-based policies operate *inside* the boundary
- Even if a policy grants more, the boundary caps it
- Key use case: safely delegating IAM to developers without enabling privilege escalation

### 4. Session Policies
Passed programmatically when calling `AssumeRole` or `GetFederationToken`.
- Further restrict (never expand) permissions for a specific session
- Temporary and in-memory only — the underlying role is unchanged
- Common in SSO and federation systems

---

## JSON Policy Anatomy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "OptionalStatementId",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:root"},
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

| Field | Notes |
|---|---|
| `Version` | Always `"2012-10-17"` |
| `Sid` | Optional statement identifier |
| `Effect` | `Allow` or `Deny` only |
| `Principal` | Only in resource-based policies — who this applies to |
| `Action` | `service:operation` format. Wildcards supported (`s3:*`, `s3:Get*`) |
| `Resource` | ARN of the resource being acted on |
| `Condition` | Optional — when the rule applies |

---

## IAM Evaluation Logic

### Evaluation Order

Explicit Deny         → STOP. Denied. No exceptions.
SCPs                  → (Organizations) Does the org allow this?
Resource-based policy → Does the resource policy Allow?
Permission boundary   → Does the boundary allow this?
Session policy        → Does the session policy allow this?
Identity-based policy → Does the identity policy allow this?
↓
No explicit Allow found → IMPLICIT DENY
### The Two Rules That Explain Everything
1. **Explicit Deny always wins** — regardless of any other allows
2. **No explicit Allow = Deny** — silence is not permission

### Same-Account vs. Cross-Account Access
**Same account:** Identity-based policy OR resource-based policy is sufficient.

**Cross-account:** Both must allow.
- The IAM identity in Account A needs permission AND
- The resource in Account B must grant it via resource-based policy

---

## Lab: Policies Written and Tested

### Policy 1 — S3 GetObject Restricted to a Specific VPC
**File:** `policy-1-s3-vpc.json`

Allows `s3:GetObject` on a specific bucket only when the request originates from a designated VPC using the `aws:SourceVpc` global condition key.

**Key learnings:**
- `aws:SourceVpc` checks where the request comes from, not where the bucket lives
- S3 is a global service — buckets don't live in a VPC
- For production use, requests should go through a VPC Gateway Endpoint for reliable condition evaluation
- When `aws:SourceVpc` context key is absent, the condition fails → implicit deny

### Policy 2 — EC2 DescribeInstances Restricted to us-east-1
**File:** `policy-2-ec2-region.json`

Allows `ec2:DescribeInstances` only when `aws:RequestedRegion` equals `us-east-1`. Requests from any other region are denied.

**Key learnings:**
- `ec2:DescribeInstances` requires `Resource: "*"` — it's a list operation, not a single-resource action
- Missing context keys cause condition failure → implicit deny
- Tested both us-east-1 (allow) and us-east-2 (deny) in the simulator

### Policy 3 — Allow All, Deny Deletion of Production-Tagged Resources
**File:** `policy-3-deny-production.json`

Allows all actions, but explicitly denies deletion operations on any resource tagged `Environment: production`.

**Key learnings:**
- `aws:ResourceTag` checks the tag on the resource being acted on
- Distinct from `aws:PrincipalTag` (tag on the caller) and `aws:RequestTag` (tag being set)
- Explicit Deny overrides the Allow * — evaluation logic confirmed in simulator
- Testing with `Environment: staging` allowed; `Environment: production` denied

---

## Tools Used
- **AWS IAM Console** — policy creation
- **IAM Policy Simulator** — https://policysim.aws.amazon.com
  - Policies must be attached to a user, group, or role to simulate
  - Context keys must be manually injected for condition evaluation
  - Resource ARNs must match exactly (e.g. `arn:aws:s3:::bucket-name/*` not `*`)
