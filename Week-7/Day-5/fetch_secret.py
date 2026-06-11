import boto3
import json

def get_db_credentials(secret_name, region):
    client = boto3.client('secretsmanager', region_name=region)
    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response['SecretString'])
    return secret

def connect_to_db(credentials):
    print("Connecting to database...")
    print(f"  Host:     {credentials['host']}")
    print(f"  Port:     {credentials['port']}")
    print(f"  Database: {credentials['dbname']}")
    print(f"  Username: {credentials['username']}")
    print(f"  Password: {'*' * len(credentials['password'])}")
    print("Credentials fetched from Secrets Manager — no hardcoded values.")

if __name__ == "__main__":
    SECRET_NAME = "prod/rds/mysql"
    REGION = "us-east-2"

    credentials = get_db_credentials(SECRET_NAME, REGION)
    connect_to_db(credentials)
