# frozen_string_literal: true

FactoryGirl.define do

  factory :repository do
    sequence(:name) { |n| "organization/repository-#{n}" }
    repo_list
  end
end
