# frozen_string_literal: true

module Slack
  ##
  # Slack configuration
  class Configuration

    class_attribute :verification_code
    class_attribute :team_domain
    class_attribute :webhook_url

    def self.from_environment!
      self.verification_code = ENV['SLACK_VERIFICATION_CODE']
      self.team_domain = ENV['SLACK_TEAM_DOMAIN']
      self.webhook_url = ENV['SLACK_WEBHOOK_URL']
    end

  end
end
