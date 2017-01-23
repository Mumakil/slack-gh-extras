# frozen_string_literal: true

FactoryGirl.define do

  factory :user do
    sequence(:github_id, 1000)
    github_handle { "github-handle-#{github_id}" }
    github_token { FactoryGirl.generate(:github_token) }

    sequence(:slack_id, 2000) { |n| "U#{n}" }
    slack_handle { "slack-handle-#{slack_id}" }
  end
end
