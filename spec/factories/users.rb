# frozen_string_literal: true

FactoryGirl.define do

  factory :user do
    trait :with_github_data do
      sequence(:github_id, 1000)
      github_token { "github-token-#{github_id}" }
      github_handle { "github-handle-#{github_id}" }
    end

    trait :with_slack_data do
      sequence(:slack_id, 2000) { |n| "U#{n}" }
      slack_handle { "slack-handle-#{slack_id}" }
    end
  end
end
