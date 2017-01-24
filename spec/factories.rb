# frozen_string_literal: true

FactoryGirl.define do

  sequence :token do |n|
    Base64.urlsafe_encode64(
      Digest::SHA256.hexdigest(
        "sometokenbase-#{n}"
      )
    )[0...15]
  end

  sequence :domain do |n|
    "domain-#{n}"
  end

  sequence :webhook_url do |n|
    "https://hooks.example.com/hook-#{n}"
  end
end
