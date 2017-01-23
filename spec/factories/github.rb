# frozen_string_literal: true

FactoryGirl.define do

  sequence(:github_id, 100_000)
  sequence(:github_token) { |n| "github-token-#{n}" }
  sequence(:github_handle) { |n| "github-handle-#{n}" }
  sequence(:repository_name) { |n| "org/repository-#{n}" }

  factory :sawyer_agent, class: Sawyer::Agent do
    transient do
      stubs { Faraday::Adapter::Test::Stubs.new }
    end
    initialize_with do
      new 'https://api.github.com/' do |conn|
        conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
        conn.adapter :test, stubs
      end
    end
  end

  factory :github_user_operation, class: Github::Operations::FetchUser do
    transient do
      token { generate(:github_token) }
    end

    trait :with_response do
      transient do
        github_id
        github_handle
      end

      user do
        Sawyer::Resource.new(
          build(:sawyer_agent),
          id: github_id,
          login: github_handle,
          _links: { self: { href: '/' } }
        )
      end

      scopes { ['repo'] }
    end

    initialize_with { new(token) }
  end

  factory :github_pulls_operation, class: Github::Operations::FetchPullRequests do
    transient do
      token { generate(:github_token) }
      names { generate_list(:repository_name, 5) }
    end

    trait :with_response do

    end

    initialize_with { new(token, names) }
  end
end