# frozen_string_literal: true

module Slack
  ##
  # Slack configuration
  class Configuration

    class_attribute :command
    class_attribute :command_token
    class_attribute :team_domain

    def self.from_environment!
      self.command = ENV['SLACK_COMMAND']
      self.command_token = ENV['SLACK_COMMAND_TOKEN']
      self.team_domain = ENV['SLACK_TEAM_DOMAIN']
    end

  end
end
