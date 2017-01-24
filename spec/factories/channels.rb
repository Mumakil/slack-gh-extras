# frozen_string_literal: true

FactoryGirl.define do

  factory :channel do
    sequence(:name) { |n| "channel-#{n}" }
    sequence(:slack_id, 10_000) { |n| "C#{n}" }
    default_repositories { create(:repo_list).name }
  end
end
