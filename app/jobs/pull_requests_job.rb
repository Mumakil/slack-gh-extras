# frozen_string_literal: true

require 'slack-notifier'

##
# Notifies a channel when defaults are changed
class PullRequesteJob < ApplicationJob

  def perform(repositories, original_query, user_id, slack_url)
    with_connection_pool do
      user = User.find(user_id)
      unauthorized = []
      not_found = []
      pull_requests = repositories.map do |repo_name|
        begin
          operation = fetch_repo_operation(user.github_token, repo_name)
          operation.pull_requests
        rescue Github::ErrUnauthorized
          unauthorized << repo_name
        rescue Github::ErrNotFound
          not_found << repo_name
        end
      end.flatten.sort do |a, b|
        if a[:created_at] == b[:created_at]
          0
        elsif a[:created_at] < b[:created_at]
          -1
        else
          1
        end
      end

      if pull_requests.empty?
        slack_notifier(slack_url).post(
          text: "There were no open pull requests in `#{original_query}`",
          response_type: 'in_channel'
        )
      else

      end

    end
  rescue RuntimeError => e
    slack_notifier(slack_url).post(
      text: "There was an error when trying to fetch pull requests: #{e.message}",
      response_type: 'ephemeral'
    )
  end

  def fetch_repo_operation(token, repo_name)
    Github::Operations::FetchPullRequests.new(token, repo_name).execute!
  end
end
