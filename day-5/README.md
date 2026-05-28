# Week 5 Day 5 — DynamoDB

## What I built
- A DynamoDB `Users` table with `userId` (PK) and `email` (SK)
- A Global Secondary Index on `email` for user lookups by email
- A Lambda function (`dynamo-user-lookup`) that reads from the table by userId + email

## Key concepts
- NoSQL table design around access patterns, not schema
- GSI lets you query on attributes outside the primary key
- Lambda + DynamoDB is the core serverless pattern on AWS

## CLI commands used
- `aws dynamodb create-table`
- `aws dynamodb put-item`, `get-item`, `query`
- `aws dynamodb update-table` (add GSI)
- `aws lambda create-function` + `invoke`
