# Serverless URL Shortener

A fully serverless URL shortener built on AWS.

## Architecture
- **API Gateway** — HTTP API with two routes
- **Lambda** — createShortUrl + redirectUrl (Python 3.12)
- **DynamoDB** — stores short code → long URL mappings with 7-day TTL
- **S3** — hosts static frontend with lifecycle policy

## Endpoints
- `POST /shorten` — accepts `{ "longUrl": "..." }`, returns short code
- `GET /{shortCode}` — 302 redirect to original URL

## Live Frontend
http://url-shortener-frontend-455919270027.s3-website.us-east-2.amazonaws.com

## Key Design Decisions
- 302 (not 301) redirects so TTL expiration is enforced on every request
- PAY_PER_REQUEST billing on DynamoDB for unpredictable traffic
- CORS enabled on API Gateway for browser-based frontend access
