# Week 5 Day 1 — S3 Deep Dive

## Lab: Versioning, Bucket Policies, Pre-Signed URLs, SSE-KMS

### What I built
- Versioned S3 bucket with CLI-managed object versions
- Bucket policy restricting access to a specific IAM identity + enforcing HTTPS
- Pre-signed URL generation and expiration verification
- SSE-KMS encryption with BucketKeyEnabled

### Key commands

**Enable versioning**
```bash
aws s3api put-bucket-versioning \
  --bucket BUCKET-NAME \
  --versioning-configuration Status=Enabled
```

**List all versions of an object**
```bash
aws s3api list-object-versions --bucket BUCKET-NAME
```

**Download a specific version**
```bash
aws s3api get-object \
  --bucket BUCKET-NAME \
  --key test.txt \
  --version-id VERSION-ID \
  output-file.txt
```

**Generate a pre-signed URL (5 min expiry)**
```bash
aws s3 presign s3://BUCKET-NAME/file.txt --expires-in 300
```

**Enable SSE-KMS encryption**
```bash
aws s3api put-bucket-encryption \
  --bucket BUCKET-NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms"
      },
      "BucketKeyEnabled": true
    }]
  }'
```

### What I learned
- Delete markers vs permanent deletion in versioned buckets
- Bucket policies are resource-based; IAM policies are identity-based — cross-account access requires both
- Pre-signed URLs are hard to revoke — keep expiry times short
- SSE-KMS logs every decryption in CloudTrail; SSE-S3 does not
