# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Token sets or clears accesstoken
    class RepoLists < Slack::Command

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

      def repository_names
        tokenized_arguments[2..-1].uniq
      end

      def process!
        return process_show_list! if action.blank?
        case action
        when 'add'
          process_add_action!
        when 'remove'
          process_remove_action!
        else
          raise ArgumentError, 'Unknown action'
        end
      end

      def process_show_list!
        lists = RepoList.includes(:repositories).all
        return 'Nobody has created any repository lists.' if lists.empty?
        "Here are the currently configured repository lists:\n\n" +
          lists.map do |repo_list|
            '    - ' + format_repo_list(repo_list)
          end.join("\n")
      end

      def process_add_action!
        return 'No repositories to add.' if repository_names.empty?
        RepoList.transaction do
          repo_list = RepoList.find_or_create_by!(name: list_name)
          repository_names.each do |repo_name|
            begin
              repo_list.repositories << Repository.new(name: repo_name)
            rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
              nil
            end
          end
        end
        repo_list = RepoList.includes(:repositories).find_by_name!(list_name)
        "Ok, here's the list now:\n\n" \
        '    - ' + format_repo_list(repo_list)
      end

      def process_remove_action!
        return 'No repositories to remove.' if repository_names.empty?
        RepoList.transaction do
          repo_list = RepoList.find_by_name(list_name)
          return 'No such list.' if repo_list.nil?
          repository_names.each do |repo_name|
            repo_list.repositories.find_by_name(repo_name)&.destroy!
          end
        end
        repo_list = RepoList.includes(:repositories).find_by_name!(list_name)
        if repo_list.repositories.count.zero?
          repo_list.destroy!
          'Ok, the list has been deleted.'
        else
          "Ok, here's the list now:\n\n" \
          '    - ' + format_repo_list(repo_list)
        end
      end

      def format_repo_list(repo_list)
        repo_list.name + ': ' + repo_list.repositories.map do |repository|
          "<#{repository.url}|#{repository.name}>"
        end.join(', ')
      end

    end
  end
end
