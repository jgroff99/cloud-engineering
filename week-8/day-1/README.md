# Week 8 Day 1 - CloudWatch Monitoring Stack

## What Was Built
- CloudWatch agent on EC2 collecting memory metrics and system logs
- SNS topic `cloudwatch-alerts` with email subscription
- CloudWatch alarm: EC2-High-CPU (threshold: 70%, evaluation: 2x60s periods)
- Custom metric: MyApp/ErrorCount published via CLI
- CloudWatch dashboard: CloudEngineering (4 widgets)
- Logs Insights query against /ec2/cloud-engineering log group

## Architecture
EC2 (cloud-engineering-ec2 / i-0f8e3c6a1aeca62e1)
  └── CloudWatch Agent
        ├── Metrics → CWAgent namespace (mem_used_percent)
        └── Logs → /ec2/cloud-engineering (30-day retention)

Custom App Metrics → MyApp namespace (ErrorCount)

CloudWatch Alarms
  └── EC2-High-CPU → SNS → cloudwatch-alerts → email

## Key Commands
```bash
# Publish custom metric
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "ErrorCount" \
  --value 1 \
  --unit Count \
  --region us-east-2

# Query logs
aws logs start-query \
  --log-group-name "/ec2/cloud-engineering" \
  --start-time $(date -v-1H +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | sort @timestamp desc | limit 20' \
  --region us-east-2
```

## Resources Created
- EC2: i-0f8e3c6a1aeca62e1 (cloud-engineering-ec2)
- Elastic IP: eipalloc-07293a35f0a4a2524
- SNS Topic: arn:aws:sns:us-east-2:ACCOUNT_ID:cloudwatch-alerts
- Log Group: /ec2/cloud-engineering
- Dashboard: CloudEngineering
- Alarm: EC2-High-CPU
