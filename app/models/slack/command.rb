# frozen_string_literal: true

module Slack
  ##
  # Command represents an incoming slack /command
  class Command
    include ActiveModel::Model

    COMMANDS = {
      help: Slack::Commands::Help
    }.with_indifferent_access
    COMMANDS.default = Slack::Command
    COMMANDS.freeze

    attr_accessor :token, :team_domain, :channel_name, :user_id, :user_name,
                  :command, :text, :response_url

    validates_each :token do |record, attr, value|
      unless value == Slack::Configuration.command_token
        record.errors.add(attr, 'is invalid')
      end
    end

    validates_each :team_domain do |record, attr, value|
      unless value == Slack::Configuration.team_domain
        record.errors.add(attr, 'is not allowed')
      end
    end

    validates_each :command do |record, attr, value|
      unless value == Slack::Configuration.command
        record.errors.add(attr, 'is not allowed')
      end
    end

    validates_each :subcommand do |record, _attr, value|
      unless COMMANDS.key?(value)
        record.errors[:base] <<
          "'#{value}' is not a known subcommand. " \
          "Type `/#{Slack::Configuration.command} help` to see command help."
      end
    end

    def self.subclass_from_params(params)
      subcommand = parse_subcommand(params[:text])
      COMMANDS[subcommand].new(params)
    end

    def self.parse_subcommand(text)
      if text.blank?
        ''
      else
        text.split(/\s+/).first
      end
    end

    def subcommand
      self.class.parse_subcommand(text)
    end

  end

end
