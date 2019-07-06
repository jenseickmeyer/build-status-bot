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
    post_message "Pipeline execution has #{state.downcase}"
  elsif detail_type == "CodePipeline Stage Execution State Change"
    stage = event["detail"]["stage"]
    state = event["detail"]["state"]

    if stage == "Build"
      post_message "Build has #{state.downcase}"
    elsif stage == "Deploy"
      post_message "Deployment has #{state.downcase}"
    end
  end

end

def post_message (message)
  uri = URI.parse(SLACK_WEBHOOK_URL)

  header = { 'Content-Type': 'application/json' }
  # TODO: Provide more information
  message = { text: message }

  # Create the HTTP objects
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = message.to_json

  # Send the request
  response = http.request(request)
end
