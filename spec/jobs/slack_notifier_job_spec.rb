# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe SlackNotifierJob, type: :job do

  let(:url) { FactoryGirl.generate(:webhook_url) }

  before :each do
    stub_request(:post, url)
      .with(
        body: {
          "payload" => "{\"text\":\"my message\",\"response_type\":\"in_channel\"}"
        }
      )
      .to_return(:status => 200, :body => "", :headers => {})
  end

  it 'sends notification' do
    SlackNotifierJob.new.perform(url, 'my message')
  end

end
