import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')
table = dynamodb.Table('url-shortener')

def lambda_handler(event, context):
    short_code = event['pathParameters']['shortCode']

    response = table.get_item(Key={'shortCode': short_code})

    if 'Item' not in response:
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Short URL not found or expired'})
        }

    long_url = response['Item']['longUrl']

    return {
        'statusCode': 302,
        'headers': {'Location': long_url},
        'body': ''
    }
