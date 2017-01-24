# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe PullRequestsJob, type: :job do

  let(:url) { FactoryGirl.generate(:webhook_url) }
  let(:user) { FactoryGirl.create(:user) }
  let(:repositories) { FactoryGirl.generate_list(:repository_name, 4) }

  describe '#perform' do

    context 'when all repositories succeed' do

      subject { PullRequestsJob.new }
      let(:pr_operation) do
        FactoryGirl.build(
          :github_pulls_operation,
          :with_response,
          names: repositories,
          failed_count: 0
        )
      end

      it 'sends open pull requests message to slack' do
        allow(subject).to receive(:fetch_repositories_operation)
          .with(user.github_token, repositories)
          .and_return(pr_operation)
        # TODO: verify payload
        stub_request(:post, url)
          .to_return(status: 200, body: '{}', headers: {})
        subject.perform(repositories, repositories, user.id, url)
      end

    end

    context 'when some repositories fail' do
      let(:successfull_repos) { repositories.first(2) }
      let(:failed_repos) { repositories.last(2) }
    end
  end

end
