# frozen_string_literal: true

FactoryGirl.define do

  factory :repo_list do
    sequence(:name) { |n| "repo-list-#{n}" }

    trait :with_repositories do
      transient do
        repo_count 5
      end

      after(:create) do |repo_list, evaluator|
        create_list(:repository, evaluator.repo_count, repo_list: repo_list)
      end
    end
  end
end
