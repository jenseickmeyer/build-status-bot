require 'net/http'
require 'uri'
require 'json'
require 'aws-sdk'

SLACK_WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
PIPELINE_NAME = ENV['PIPELINE_NAME']

def handler(event:, context:)
  pipeline_name = event["detail"]["pipeline"]
  execution_id = event["detail"]["execution-id"]

  if pipeline_name != PIPELINE_NAME
    puts "No matching pipeline"
    return nil
  end

  commit_id = get_commit_id pipeline_name, execution_id

  detail_type = event["detail-type"]
  if detail_type == "CodePipeline Pipeline Execution State Change"
    state = event["detail"]["state"]
    if state == "STARTED"
      post_message ":hammer_and_wrench: Build for commit `#{commit_id[0, 7]}` has started"
    end
  elsif detail_type == "CodePipeline Stage Execution State Change"
    stage = event["detail"]["stage"]
    state = event["detail"]["state"]

    if stage == "Build"
      if state == "SUCCEEDED"
        post_message ":hammer_and_wrench: Build for commit `#{commit_id[0, 7]}` has finished successfully", "good"
      elsif state == "FAILED"
        post_message ":hammer_and_wrench: Build for commit `#{commit_id[0, 7]}` has failed", "danger"
      end

    elsif stage == "Deploy"
      if state == "SUCCEEDED"
        post_message ":package: Deployment for commit `#{commit_id[0, 7]}` has finished successfully", "good"
      elsif state == "FAILED"
        post_message ":package: Deployment for commit `#{commit_id[0, 7]}` has has failed", "danger"
      end
    end
  end

end

def get_commit_id (pipeline_name, execution_id)
  codepipeline = Aws::CodePipeline::Client.new()
  result = codepipeline.get_pipeline_execution({
    pipeline_name: pipeline_name,
    pipeline_execution_id: execution_id
  })

  sha = result.pipeline_execution.artifact_revisions[0].revision_id
end

def post_message (message, color = "gray")
  uri = URI.parse(SLACK_WEBHOOK_URL)

  header = { 'Content-Type': 'application/json' }
  # TODO: Provide more information
  message = { attachments: [ { fallback: message, color: color, text: message, mrkdwn_in: [ "text" ] } ] }

  # Create the HTTP objects
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = message.to_json

  # Send the request
  response = http.request(request)
end
