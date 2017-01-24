# frozen_string_literal: true

FactoryGirl.define do

  factory :user do
    github_id
    github_handle
    github_token

    sequence(:slack_id, 2000) { |n| "U#{n}" }
    slack_handle { "slack-handle-#{slack_id}" }
  end
end
