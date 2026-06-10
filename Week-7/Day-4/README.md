# Week 7 Day 4 — KMS Lab

## Resources Created
- KMS customer-managed key: `alias/week7-lab-key` (us-east-2)
- S3 bucket SSE-KMS: `ce-versioning-lab-jgroff99` using CMK
- EBS volume: `vol-0be29e44fe41ff440` encrypted with CMK

## What Was Demonstrated
- Created a CMK with a key policy (root enablement, admin access)
- Encrypted/decrypted a string directly via CLI
- Enabled SSE-KMS on an existing S3 bucket
- Created an encrypted EBS volume using CMK
- Audited KMS API calls in CloudTrail

## Key Concepts
- Envelope encryption: KMS encrypts the data key, not the data itself
- Key policy root statement required or IAM policies cannot grant KMS access
- BucketKeyEnabled reduces KMS API calls by caching at bucket level
- Every KMS operation is logged in CloudTrail — full audit trail
