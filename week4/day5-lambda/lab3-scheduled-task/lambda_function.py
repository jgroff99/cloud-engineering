import json
import urllib.request
import logging
from datetime import datetime, timezone

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ENDPOINT_URL = "https://httpbin.org/get"


def lambda_handler(event, context):
    run_time = datetime.now(timezone.utc).isoformat()
    logger.info(f"Scheduled run started at {run_time}")

    try:
        req = urllib.request.Request(
            ENDPOINT_URL,
            headers={'User-Agent': 'AWS-Lambda-Scheduler/1.0'}
        )
        with urllib.request.urlopen(req, timeout=10) as response:
            status = response.status
            body = json.loads(response.read())

        logger.info(f"Endpoint responded: HTTP {status}")
        return {
            'statusCode': 200,
            'body': json.dumps({'run_time': run_time, 'endpoint_status': status})
        }

    except Exception as e:
        logger.error(f"Endpoint call failed: {str(e)}")
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
