#!/usr/bin/env bash

S3_BUCKET=
INPUT_FILE=template.yaml
OUTPUT_FILE=template-output.yaml
REGION=
STACK_NAME=build-status-bot

aws cloudformation package --template-file $INPUT_FILE \
                           --s3-bucket $S3_BUCKET \
                           --output-template-file $OUTPUT_FILE
aws cloudformation deploy --template-file $OUTPUT_FILE \
                          --stack-name $STACK_NAME \
                          --parameter-overrides SlackWebhookURL= \
                                                CodePipelineName= \
                          --capabilities CAPABILITY_NAMED_IAM \
                          --region $REGION \
