# Week 5 Day 2 — S3 Lifecycle Policies + Static Website Hosting

## What's in this folder

- `lifecycle.json` — S3 lifecycle rule transitioning objects to IA (30d), Glacier (90d), Deep Archive (365d), expiring at 2555d. Applied to the `logs/` prefix.
- `index.html` / `error.html` — Static website hosted on S3.

## Live site
http://my-portfolio-site-1779842225.s3-website.us-east-2.amazonaws.com

## Commands used

### Apply lifecycle rule
```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket YOUR-BUCKET \
  --lifecycle-configuration file://lifecycle.json
```

### Verify lifecycle rule
```bash
aws s3api get-bucket-lifecycle-configuration --bucket YOUR-BUCKET
```

### Enable static website hosting
```bash
aws s3api put-bucket-website \
  --bucket YOUR-BUCKET \
  --website-configuration '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"error.html"}}'
```
