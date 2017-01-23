# frozen_string_literal: true

require 'base64'
require 'digest'

def slack_test_configuration!
  Slack::Configuration.command = '/github'
  Slack::Configuration.command_token = FactoryGirl.generate(:token)
  Slack::Configuration.team_domain = FactoryGirl.generate(:domain)
end
