# Build Status Bot

This serverless application provides a solution for posting messages about the status of AWS CodePipeline executions to Slack. This way the success or failure of a build pipeline can be easily tracked by developers.

The application is based on the *Serverless Application Model* (SAM) provided by AWS. Basically, it simply consists of a Lambda function which subscribes to CloudWatch Events to get notified once states for CodePipeline pipelines change.

## Install
Installing the application is pretty straight-forward. As a pre-requiste, the AWS CLI needs to be installed on the machine from which the deployment should be performed.

First, you need to create a *Personal Access Token* in GitHub and store it to the Parameter Store of the AWS Systems Manager. You need to do this in the AWS region into which you want to deploy the application. This can either be done via the AWS Console or the following AWS CLI command:

```bash
aws ssm put-parameter --name /github/personal_access_token --value TOKEN --type String
```

It's important to use the key `/github/personal_access_token` since this is used in the SAM template.

Next, the deployment script `deploy.sh` must be changed slightly. The variables `S3_BUCKET` must be set to the name of the S3 bucket into which deployment artifacts should be stored. If in doubt it makes sense to create a new bucket for this purpose. Other things can be changed, too, like the name of the CloudFormation stack that will be created for this application.

Additionally, you need to create an Incoming Webhook for your Slack team and assign the URL of the webhook to the variable `SLACK_WEBHOOK_URL` in `deploy.sh`. Furthermore, you need to assign the name of the CodePipeline to the variable `CODE_PIPELINE_NAME`.

Finally, the deployment script can just be executed

```bash
bash deploy
```
