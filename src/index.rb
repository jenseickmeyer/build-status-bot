require 'net/http'
require 'uri'
require 'json'

SLACK_WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
PIPELINE_NAME = ENV['PIPELINE_NAME']

def handler(event:, context:)
  pipeline_name = event["detail"]["pipeline"]

  if pipeline_name != PIPELINE_NAME
    puts "No matching pipeline"
    return nil
  end

  detail_type = event["detail-type"]
  if detail_type == "CodePipeline Pipeline Execution State Change"
    state = event["detail"]["state"]
    if state == "STARTED"
      post_message "A new build has just started"
    end
  elsif detail_type == "CodePipeline Stage Execution State Change"
    stage = event["detail"]["stage"]
    state = event["detail"]["state"]

    if stage == "Build"
      if state == "SUCCEEDED"
        post_message ":hammer_and_wrench: The build has finished successfully.", "good"
      elsif state == "FAILED"
        post_message ":hammer_and_wrench: The build has failed", "danger"
      end

    elsif stage == "Deploy"
      if state == "SUCCEEDED"
        post_message ":package: Deployment has finished successfully", "good"
      elsif state == "FAILED"
        post_message ":package: Deployment has has failed", "danger"
      end
    end
  end

end

def post_message (message, color = "gray")
  uri = URI.parse(SLACK_WEBHOOK_URL)

  header = { 'Content-Type': 'application/json' }
  # TODO: Provide more information
  message = { attachments: [ { fallback: message, color: color, text: message } ] }

  # Create the HTTP objects
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = message.to_json

  # Send the request
  response = http.request(request)
end
