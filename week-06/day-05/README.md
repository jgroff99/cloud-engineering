# Week 6 Day 5 — CloudFront CDN

## Architecture
CloudFront distribution in front of S3 static site with Origin Access Control (OAC).
S3 bucket is fully private — accessible only via CloudFront.

## Resources created
- CloudFront distribution ID: E30QO2DVPU8F8X
- CloudFront domain: d3mi882ffwva6z.cloudfront.net
- OAC ID: E2E3LCT7QCXLRI
- Origin: my-portfolio-site-1779842225 (us-east-2)

## Key concepts demonstrated
- OAC locks S3 bucket to a specific CloudFront distribution via bucket policy condition
- Cache policy 658327ea (CachingOptimized) — 24h TTL for static assets
- X-Cache: Miss from cloudfront — first request, edge fetches from S3
- X-Cache: Hit from cloudfront — subsequent requests served from edge cache
- Invalidation (/*) purges all cached objects — next request is a Miss again

## Note on domain/HTTPS
Custom domain and ACM certificate skipped — requires a registered domain.
CloudFront default domain (*.cloudfront.net) provides HTTPS automatically via AWS-managed cert.
Custom domain + ACM will be revisited in the Week 8 capstone project.

## Commands reference

### Create OAC
aws cloudfront create-origin-access-control \
  --origin-access-control-config '{
    "Name": "portfolio-oac",
    "SigningProtocol": "sigv4",
    "SigningBehavior": "always",
    "OriginAccessControlOriginType": "s3"
  }'

### Test cache behavior
curl -I https://d3mi882ffwva6z.cloudfront.net/index.html 2>/dev/null | grep -E "HTTP|X-Cache"

### Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id E30QO2DVPU8F8X \
  --paths "/*"
