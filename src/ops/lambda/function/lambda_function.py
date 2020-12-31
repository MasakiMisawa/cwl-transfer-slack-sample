import boto3
import os
import logging
import time
import urllib.request
import urllib.parse
import json
import gzip
import io

## environment variable key name
S3_REGION_NAME = "S3_REGION_NAME"
SSM_REGION_NAME = "SSM_REGION_NAME"
SSM_SLACK_WEBHOOK_URL_PARAMETER_NAME = "SSM_SLACK_WEBHOOK_URL_PARAMETER_NAME"

## const value.
PRETEXT_TEMPLATE = "【---------- CWL_LOG START ----------】"
MESSAGE_BORDER_COLOR = "#FF0000"
OUTPUT_MAX_LINE_NUM = 50
HTTP_METHOD_NAME = "POST"

## singleton object
logger = None
s3 = None
ssm = None
webhook_url = None


def get_ssm_parameter_store_value(ssm, parameter_name, with_decryption):
    response = ssm.get_parameter(
        Name=parameter_name,
        WithDecryption=with_decryption
    )
    return response["Parameter"]["Value"]

def initialize_singleton_object():
    """
    Initialize singleton object.
    """
    global logger
    if not logger:
        logger = logging.getLogger()
        logger.setLevel(logging.INFO)

    global s3
    if not s3:
        s3 = boto3.resource("s3", region_name=os.environ[S3_REGION_NAME])

    global ssm
    if not ssm:
        ssm = boto3.client("ssm", region_name=os.environ[SSM_REGION_NAME])

    global webhook_url
    if not webhook_url:
        webhook_url = get_ssm_parameter_store_value(
            ssm,
            os.environ[SSM_SLACK_WEBHOOK_URL_PARAMETER_NAME],
            True
        )

def create_send_data(transfer_logs):
    send_data = "payload=" + json.dumps(
        {
            "attachments": [
                {
                    "fallback": PRETEXT_TEMPLATE,
                    "pretext": PRETEXT_TEMPLATE,
                    "color": MESSAGE_BORDER_COLOR,
                    "text": transfer_logs,
                    "mrkdwn_in": ["text"]
                }
            ]
        }
    )
    return send_data.encode("utf-8")

def post_request_to_slack(webhook_url, transfer_logs):
    request = urllib.request.Request(
        webhook_url,
        data=create_send_data(transfer_logs),
        method=HTTP_METHOD_NAME,
    )
    with urllib.request.urlopen(request) as response:
        return response.read().decode("utf-8")

def get_s3_object(s3_resource, bucket_name, file_path):
    return s3_resource.Object(bucket_name, file_path).get()

def unzip_compressed_object(compressed_object):
    return gzip.open(io.BytesIO(compressed_object), 'rt')

def cwl_transfer_slack(s3, bucket_name, file_path, webhook_url, logger):
    transfer_logs = ""
    exist_fail_request = False

    s3_object = get_s3_object(s3, bucket_name, file_path)
    cwl_content = unzip_compressed_object(s3_object["Body"].read())
    logs_line = cwl_content.read().split("\n")
    for i in range(len(logs_line)):
        log = logs_line[i].replace("'", "\\'").replace("&", "%26")
        if len(log) > 0:
            transfer_logs = transfer_logs + log + "\n"

        if i > 0 and i % OUTPUT_MAX_LINE_NUM == 0:
            try:
                post_request_to_slack(webhook_url, transfer_logs)
                logger.info(
                    "post_request_to_slack successed. transfer_logs = "
                    + transfer_logs
                )
            except Exception as e:
                logger.exception(
                    "post_request_to_slack failed. transfer_logs = "
                    + transfer_logs
                )
                exist_fail_request = True

            transfer_logs = ""
            time.sleep(3)

    if len(transfer_logs) > 0:
        try:
            post_request_to_slack(webhook_url, transfer_logs)
            logger.info(
                "post_request_to_slack successed. transfer_logs = "
                + transfer_logs
            )
        except Exception as e:
            logger.exception(
                "post_request_to_slack failed. transfer_logs = "
                + transfer_logs
            )
            exist_fail_request = True

    return exist_fail_request

def lambda_handler(event, context):
    initialize_singleton_object()

    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    file_path = urllib.parse.unquote(event["Records"][0]["s3"]['object']['key'])
    logger.info(
        "cwl_transfer_slack start. bucket_name = "
        + bucket_name
        + " file_path = "
        + file_path
    )
    exist_fail_request = cwl_transfer_slack(
        s3, bucket_name, file_path, webhook_url, logger
    )
    if exist_fail_request:
        raise Exception("Exist fail request into cwl transfer slack.")

    logger.info(
        "cwl transfer slack successed. bucket_name = "
        + bucket_name
        + " file_path = "
        + file_path
    )
