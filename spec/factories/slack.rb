# frozen_string_literal: true

FactoryGirl.define do

  factory :slack_command, class: Slack::Command do
    token { Slack::Configuration.command_token }
    team_domain { Slack::Configuration.team_domain }
    command { Slack::Configuration.command }
    text 'help'

    initialize_with { Slack::Command.subclass_from_params(attributes) }
  end
end
