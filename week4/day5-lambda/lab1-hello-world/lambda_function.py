import json


def lambda_handler(event, context):
    name = event.get('name', 'World')

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Hello, {name}!',
            'function_name': context.function_name,
            'remaining_ms': context.get_remaining_time_in_millis()
        })
    }
