# Week 4 Day 5 — AWS Lambda (Serverless Compute)

Three Python Lambda functions demonstrating the core event-driven patterns used in real cloud architectures.

## What I built

### Lab 1 — Hello World (manual invocation)
A basic Lambda function triggered manually via the AWS Console test tool. Covers the handler signature (`event`, `context`), JSON responses, and the cold start vs warm container difference observable in billed duration.

### Lab 2 — S3 Trigger (async event-driven)
A function that fires automatically whenever a file is uploaded to an S3 bucket. Parses the S3 event record to extract bucket name, object key, and file size, then logs to CloudWatch.

### Lab 3 — Scheduled Task (EventBridge cron)
A function triggered on a schedule by an EventBridge rule. Calls an HTTP endpoint, logs the response, and handles errors gracefully. Replaces traditional server-based cron jobs entirely.

## Architecture
Lab 1:  [Manual test] ─────────────────────────────► [Lambda] ──► [CloudWatch Logs]
Lab 2:  [S3 upload] ──► [S3 event notification] ──► [Lambda] ──► [CloudWatch Logs]
(async)
Lab 3:  [EventBridge rule] ──► [Scheduled event] ──► [Lambda] ──► [HTTP endpoint]
(cron)                (async)                    └──► [CloudWatch Logs]

## Services Used
| Service | Role |
|---|---|
| AWS Lambda | Serverless function execution |
| Amazon S3 | Object storage + event source (Lab 2) |
| Amazon EventBridge | Cron scheduler (Lab 3) |
| Amazon CloudWatch Logs | Logging and monitoring |
| AWS IAM | Execution roles and least-privilege permissions |

## Key Concepts
- **Cold starts** — first invocation requires AWS to provision a new container (~100ms–1s overhead). Subsequent invocations reuse the warm container.
- **Execution role** — every Lambda assumes an IAM role at runtime. Start with `AWSLambdaBasicExecutionRole` and add only what the function actually needs.
- **Init code** — code outside the handler runs once per container and persists across warm invocations. Use for SDK clients and constants.
- **Async vs sync** — S3 and EventBridge are fire-and-forget. API Gateway waits for Lambda to return before sending the HTTP response.
