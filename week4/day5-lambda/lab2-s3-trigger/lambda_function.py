import json
import urllib.parse
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(
            record['s3']['object']['key'],
            encoding='utf-8'
        )
        size = record['s3']['object']['size']
        logger.info(f"New file uploaded: s3://{bucket}/{key} ({size} bytes)")

    return {
        'statusCode': 200,
        'body': json.dumps(f'Processed {len(event["Records"])} file(s)')
    }
