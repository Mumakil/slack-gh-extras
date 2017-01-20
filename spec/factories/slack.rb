# frozen_string_literal: true

FactoryGirl.define do

  factory :slack_command, class: Slack::Command do
    token { Slack::Configuration.command_token }
    team_domain { Slack::Configuration.team_domain }
    command { Slack::Configuration.command }
    text 'help'

    trait :with_user do
      sequence(:user_id, 10_000) { |n| "U#{n}" }
      sequence(:user_name) { |n| "username-#{n}" }
    end

    trait :with_channel do
      sequence(:channel_id, 200_000) { |n| "C#{n}" }
      sequence(:channel_name) { |n| "channel-name-#{n}"}
    end

    initialize_with { Slack::Command.subclass_from_params(attributes) }
  end
end
