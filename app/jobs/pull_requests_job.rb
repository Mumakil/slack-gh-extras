# frozen_string_literal: true

require 'action_view/helpers/date_helper'
require 'slack-notifier'

##
# Notifies a channel when defaults are changed
class PullRequesteJob < ApplicationJob

  include ActionView::Helpers::DateHelper

  def perform(repositories, original_query, user_id, slack_url)
    user = nil
    with_connection_pool do
      user = User.find(user_id)
    end
    operation = fetch_repo_operation(user.github_token, repositories)
    pull_requests = operation.pull_requests
    title = "Here are the open pull requests in `#{original_query}`"
    pulls = format_pull_requests(pull_requests)
    error = if operation.failed_repositories?
              text = 'However, there was an error fetching these repositories' \
                      "    - `#{operation.failed.join('\n    - ')}`"
              { text: text }
            end
    slack_notifier(slack_url).post(
      text: title,
      attachments: [pulls, error].reject(&:nil?),
      response_type: 'in_channel'
    )
  rescue RuntimeError => e
    slack_notifier(slack_url).post(
      text: "There was an error when trying to fetch pull requests: #{e.message}",
      response_type: 'ephemeral'
    )
  end

  def fetch_repo_operation(token, repo_name)
    Github::Operations::FetchPullRequests.new(token, repo_name).execute!
  end

  def format_pull_requests(pull_requests)
    if pull_requests.empty?
      { text: 'There were no open pull requests.' }
    else
      {
        text: pull_requests.map { |pr| format_pull_request(pr) }.join('\n'),
        mrkdwn_in: ['text']
      }
    end
  end

  def format_pull_request(pull_request)
    repo = pull_request.base.repo
    formatted = "<#{pull_request.url}|#{repo.full_name}##{pull_request.number}>"
    formatted << " *#{pull_request.title}*"
    formatted << " _by #{pull_request.assignee.login}_"
    formatted << ", opened #{time_ago_in_words(Date.parse(pull_request.created_at))} ago"
  end
end
