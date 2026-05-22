import boto3
import json
from datetime import datetime, timezone

TARGET_GROUP_ARN = "arn:aws:elasticloadbalancing:us-east-2:455919270027:targetgroup/web-server-tg/728294794e48daf1"
S3_BUCKET = "my-lambda-trigger-bucket-jgroff"

def lambda_handler(event, context):
    elb_client = boto3.client("elbv2", region_name="us-east-2")
    s3_client = boto3.client("s3", region_name="us-east-2")

    # Get target health
    response = elb_client.describe_target_health(TargetGroupArn=TARGET_GROUP_ARN)
    targets = response["TargetHealthDescriptions"]

    # Build report
    report = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "target_group_arn": TARGET_GROUP_ARN,
        "total_targets": len(targets),
        "healthy": [],
        "unhealthy": []
    }

    for t in targets:
        entry = {
            "id": t["Target"]["Id"],
            "port": t["Target"]["Port"],
            "state": t["TargetHealth"]["State"]
        }
        if t["TargetHealth"]["State"] == "healthy":
            report["healthy"].append(entry)
        else:
            report["unhealthy"].append(entry)

    report["healthy_count"] = len(report["healthy"])
    report["unhealthy_count"] = len(report["unhealthy"])

    # Write to S3
    filename = f"health-reports/{datetime.now(timezone.utc).strftime('%Y-%m-%d_%H-%M-%S')}.json"
    s3_client.put_object(
        Bucket=S3_BUCKET,
        Key=filename,
        Body=json.dumps(report, indent=2),
        ContentType="application/json"
    )

    print(f"Report written to s3://{S3_BUCKET}/{filename}")
    return {"statusCode": 200, "body": f"Report saved: {filename}"}
