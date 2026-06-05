import json
import boto3
import secrets
import string
import time

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')
table = dynamodb.Table('url-shortener')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    long_url = body['longUrl']

    alphabet = string.ascii_letters + string.digits
    short_code = ''.join(secrets.choice(alphabet) for _ in range(6))

    ttl = int(time.time()) + (7 * 24 * 60 * 60)

    table.put_item(Item={
        'shortCode': short_code,
        'longUrl': long_url,
        'ttl': ttl
    })

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({'shortUrl': short_code})
    }
