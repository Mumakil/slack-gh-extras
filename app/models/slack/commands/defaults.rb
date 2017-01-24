# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Defaults is for setting channel-specific defaults
    class Defaults < Slack::Command

      VALID_ACTIONS = %w(set clear).freeze

      validates_each :action do |record, _attr, value|
        unless value.blank? || VALID_ACTIONS.include?(value)
          record.errors[:base] << "#{value} is not a valid defaults action"
        end
      end

      def action
        tokenized_arguments.first
      end

      def default_repos
        tokenized_arguments[1..-1].join(' ')
      end

      def process!
        return process_show_default! if action.blank?
        case action
        when 'set'
          process_set_default!
        when 'clear'
          process_clear_default!
        else
          raise ArgumentError, 'Unknown action'
        end
      end

      def process_show_default!
        channel = slack_channel
        if channel.nil?
          'No default repositories set for channel.'
        else
          "Default repositories for this channel are `#{channel.default_repositories}`"
        end
      end

      def process_set_default!
        return "You didn't add any repositories." if default_repos.blank?
        channel = Channel.find_or_initialize_by(slack_id: channel_id)
        channel.assign_attributes(
          name: channel_name,
          default_repositories: default_repos
        )
        channel.save!
        unless in_private_chat?
          SlackNotifierJob.perform_later(
            response_url,
            "#{user_name} set default repositories for this channel to `#{channel.default_repositories}`."
          )
        end
        "Setting `#{channel.default_repositories}` repositories and/or " \
        'lists as default for this channel.'
      end

      def process_clear_default!
        channel = slack_channel
        if channel.nil?
          'No default repositories for this channel.'
        else
          channel.destroy!
          unless in_private_chat?
            SlackNotifierJob.perform_later(
              response_url,
              "#{user_name} cleared default repositories for this channel."
            )
          end
          'Cleared default repositories for this channel.'
        end
      end
    end
  end
end
