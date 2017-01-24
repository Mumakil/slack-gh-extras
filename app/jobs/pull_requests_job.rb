# frozen_string_literal: true

require 'action_view/helpers/date_helper'
require 'slack-notifier'

##
# Notifies a channel when defaults are changed
class PullRequestsJob < ApplicationJob

  include ActionView::Helpers::DateHelper

  def perform(repositories, original_query, user_id, slack_url)
    user = with_connection_pool do
      User.find(user_id)
    end
    operation = fetch_repositories_operation(user.github_token, repositories)
    pull_requests = operation.pull_requests
    title = "*All open pull requests (#{pull_requests.size} in total)* in " \
            "`#{original_query.join(' ')}`"
    pulls = format_pull_requests(pull_requests)
    error = if operation.failed_repositories?
              text = "However, there was an error fetching these repositories:\n" \
                      "    - `#{operation.failed_repositories.join("`\n    - `")}`"
              {
                text: text,
                color: 'danger',
                mrkdwn_in: ['text']
              }
            end
    slack_notifier(slack_url).post(
      text: title + "\n\n" + pulls,
      attachments: [error].reject(&:nil?),
      response_type: 'in_channel'
    )
  rescue RuntimeError
    slack_notifier(slack_url).post(
      text: 'There was an unexpected error when trying to fetch pull requests. Please try again later.',
      color: 'danger',
      response_type: 'ephemeral'
    )
  end

  def fetch_repositories_operation(token, repo_names)
    Github::Operations::FetchPullRequests.new(token, repo_names).execute!
  end

  def format_pull_requests(pull_requests)
    if pull_requests.empty?
      'There are no open pull requests.'
    else
      pull_requests.map { |pr| format_pull_request(pr) }.join("\n")
    end
  end

  def format_pull_request(pull_request)
    repo = pull_request.base.repo
    formatted = "<#{pull_request.url}|#{repo.full_name}##{pull_request.number}>"
    formatted += " *#{pull_request.title}*"
    formatted += " _by #{pull_request.user.login}_"
    formatted += ", opened #{time_ago_in_words(pull_request.created_at)} ago"
    formatted
  end
end
