# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Token sets or clears accesstoken
    class Token < Slack::Command
      include Github::UserOperations

      VALID_ACTIONS = %w(set clear).freeze

      validates_each :action do |record, _attr, value|
        unless VALID_ACTIONS.include?(value)
          record.errors[:base] << "#{value} is not a valid token action"
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
        unless valid_scopes?(operation.scopes)
          return 'Setting token failed. One of required scopes ' \
                 "(#{Github::REQUIRED_SCOPES.join(', ')}) is missing."
        end
        destroy_existing_github_user(github_user)
        user = User.find_or_initialize_by_slack_payload(as_json)
        user.assign_attributes(
          github_id: github_user.id,
          github_handle: github_user.login,
          github_token: github_token
        )
        user.save!
        "Access token saved! You are `#{user.github_handle}` in GitHub."
      rescue Github::Error
        'Setting token failed. Your access token seems to be invalid.'
      end

      def process_clear_action!
        u = slack_user
        if u.nil?
          'No saved data present.'
        else
          u.destroy!
          'Cleared GitHub identity and access token.'
        end
      end

      def destroy_existing_github_user(github_user)
        user = User.find_by_github_id(github_user.id)
        user&.destroy!
      end
    end
  end
end
