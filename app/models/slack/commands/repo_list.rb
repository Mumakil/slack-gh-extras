# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Token sets or clears accesstoken
    class RepoList < Slack::Command

      VALID_ACTIONS = %w(add remove).freeze

      validates_each :action do |record, _attr, value|
        unless value.blank? || VALID_ACTIONS.include?(value)
          record.errors[:base] << "#{value} is not a valid repo_list action"
        end
      end

      def action
        tokenized_arguments.first
      end

      def list_name
        tokenized_arguments.second
      end

      def repos
        tokenized_arguments[2..-1]
      end

      def process!
        case action
        when ''
          process_show_list!
        when 'add'
          process_add_action!
        when 'remove'
          process_remove_action!
        else
          raise ArgumentError, 'Unknown action'
        end
      end

      def process_show_list!
        'not implemented'
      end

      def process_add_action!
        'not implemented'
      end

      def process_remove_action!
        'not implemented'
      end

    end
  end
end
