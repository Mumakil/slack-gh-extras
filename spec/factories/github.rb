# frozen_string_literal: true

FactoryGirl.define do

  sequence(:github_token) { |n| "github-token-#{n}" }

  factory :github_user_operation, class: Github::Operations::FetchUser do
    token { FactoryGirl.generate(:github_token) }
    initialize_with { Github::Operations.FetchUser.new(token) }
  end

  factory :github_pulls_operation, class: Github::Operations::FetchPullRequests do

  end
end
