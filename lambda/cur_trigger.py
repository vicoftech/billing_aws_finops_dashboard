"""
AWS Lambda function to trigger Glue crawler when CUR files are delivered to S3.

This function is triggered by EventBridge when new CUR files are uploaded to the
specified S3 bucket and prefix. It starts the Glue crawler to process the new data.
"""

import os
import boto3
import json
from botocore.exceptions import ClientError

# Initialize AWS clients
glue_client = boto3.client('glue')

def lambda_handler(event, context):
    """
    Main Lambda handler function.

    Args:
        event: EventBridge event containing S3 object creation details
        context: Lambda context object

    Returns:
        dict: Response with status and crawler information
    """
    try:
        # Get crawler name from environment variable
        crawler_name = os.environ.get('CRAWLER_NAME')
        if not crawler_name:
            raise ValueError("CRAWLER_NAME environment variable is not set")

        print(f"Starting Glue crawler: {crawler_name}")

        # Start the Glue crawler
        response = glue_client.start_crawler(Name=crawler_name)

        print(f"Successfully started crawler: {crawler_name}")
        print(f"Response: {json.dumps(response, indent=2, default=str)}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully started Glue crawler: {crawler_name}',
                'crawler_name': crawler_name,
                'response': response
            })
        }

    except ClientError as e:
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']

        print(f"AWS Error ({error_code}): {error_message}")

        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': error_code,
                'message': error_message,
                'crawler_name': crawler_name if 'crawler_name' in locals() else None
            })
        }

    except Exception as e:
        error_message = str(e)
        print(f"Unexpected error: {error_message}")

        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'InternalServerError',
                'message': error_message,
                'crawler_name': crawler_name if 'crawler_name' in locals() else None
            })
        }
