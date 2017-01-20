# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Whoami revalidates github token
    class Whoami < Slack::Command
      include Github::UserOperations

      def process!
        user = slack_user
        return "I don't know who you are on GitHub." if user.nil?
        operation = fetch_user!(user.github_token)
        unless valid_scopes?(operation.scopes)
          user.destroy!
          return 'Your saved GitHub token is invalid. One of required scopes ' \
                 "(#{Github::REQUIRED_SCOPES.join(', ')}) is missing. " \
                 "You'll need to set new access token."
        end
        "You are `#{user.github_handle}` in GitHub and your access token seems to be ok."
      rescue Github::ErrUnauthorized
        user.destroy!
        "Your access token seems to be invalid. You'll need to set new access token."
      end
    end
  end
end
