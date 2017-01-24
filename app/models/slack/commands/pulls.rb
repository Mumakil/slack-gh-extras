# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Pulls fetches pull request information from GitHub
    class Pulls < Slack::Command

      def repository_list
        repos = tokenized_arguments.dup
        if repos.empty?
          channel = slack_channel
          unless channel.nil?
            repos.concat(channel.default_repositories.split(/\s+/))
          end
        end
        repos
      end

      def resolved_repositories
        repository_list.map do |repo_entry|
          if repo_entry.match?(%r{\/})
            repo_entry
          else
            repo_list = RepoList.find_by_name(repo_entry)
            if repo_list.nil?
              []
            else
              repo_list.repositories.pluck(:name)
            end
          end
        end.flatten.reject(&:nil?).uniq
      end

      def process!
        repo_names = resolved_repositories
        if resolved_repositories.empty?
          "There is no default for this channel, you'll need to specify " \
          'a repository or a list to query.'
        else
          user = slack_user
          if slack_user.nil?
            "You haven't set GitHub access token yet so I can't do this."
          else
            PullRequestsJob.perform_later(
              repo_names,
              repository_list,
              user.id,
              response_url
            )
            "Got it, fetching pull requests for repositories `#{repo_names.join(', ')}`"
          end
        end
      end

    end
  end
end
