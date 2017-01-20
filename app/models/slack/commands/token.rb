# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Token sets or clears accesstoken
    class Token < Slack::Command

      VALID_ACTIONS = %w(set clear).freeze
      REQUIRED_SCOPES = %w(repo).freeze

      validates_each :action do |record, _attr, value|
        unless VALID_ACTIONS.include?(value)
          record.errors[:base] << "#{value} is not a valid accesstoken action"
        end
      end

      def action
        tokenized_arguments.first
      end

      def github_token
        tokenized_arguments.second
      end

      def process!
        case action
        when 'set'
          process_set_action!
        when 'clear'
          process_clear_action!
        else
          raise ArgumentError, 'Unknown action'
        end
      end

      def process_set_action!
        operation = fetch_user!(github_token)
        github_user = operation.user
        if REQUIRED_SCOPES & operation.scopes != REQUIRED_SCOPES
          return 'Setting token failed. One of required scopes ' \
                 "(#{REQUIRED_SCOPES.join(', ')}) is missing."
        end
        destroy_existing_github_user(github_user)
        user = slack_user
        user.assign_attributes(
          github_id: github_user[:id],
          github_handle: github_user[:login],
          github_token: github_token
        )
        user.save!
        "Access token saved! You are `#{user.github_handle}` in GitHub."
      rescue Github::ErrUnauthorized
        'Setting token failed. Your access token seems to be invalid.'
      end

      def process_clear_action!
        u = slack_user
        if u.new_record?
          'No saved data present.'
        else
          u.destroy!
          'Cleared GitHub identity and access token.'
        end
      end

      def fetch_user!(token)
        Github::Operations::FetchUser.new(token).execute!
      end

      def destroy_existing_github_user(github_user)
        user = User.find_by_github_id(github_user[:id])
        user&.destroy!
      end
    end
  end
end