# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Github::Operations::FetchPullRequests, type: :model do

  describe '#execute!' do

    subject { FactoryGirl.build(:github_pulls_operation) }

    context 'with valid access token' do

      let(:responses) do
        pr_number = 0
        subject.names.reduce({}) do |memo, repo_name|
          memo[repo_name] = [
            { number: pr_number += 1, created_at: pr_number.days.ago },
            { number: pr_number += 1, created_at: pr_number.hours.ago }
          ]
          memo
        end
      end

      before :each do
        responses.each do |name, data|
          stub_request(:get, "https://api.github.com/repos/#{name}/pulls?state=open")
            .with(
              headers: {
                'Authorization' => "token #{subject.token}"
              }
            )
            .to_return(
              status: 200,
              body: JSON.dump(data),
              headers: {
                'Content-Type': 'application/json'
              }
            )
        end
        subject.execute!
      end

      it 'returns sorted pull requests' do
        expect(subject.pull_requests.size).to equal(subject.names.size * 2)
        first = subject.pull_requests.first
        last = subject.pull_requests.last
        expect(first.created_at < last.created_at).to be true
      end

      it 'has no failed repositories' do
        expect(subject.failed_repositories).to be_empty
      end
    end

    context 'with invalid access token' do

      let(:successfull_responses) do
        pr_number = 0
        subject.names.first(2).reduce({}) do |memo, repo_name|
          memo[repo_name] = [
            { number: pr_number += 1, created_at: pr_number.days.ago },
            { number: pr_number += 1, created_at: pr_number.hours.ago }
          ]
          memo
        end
      end

      let(:failed_responses) do
        subject.names.last(3)
      end

      before :each do
        successfull_responses.each do |name, data|
          stub_request(:get, "https://api.github.com/repos/#{name}/pulls?state=open")
            .with(
              headers: {
                'Authorization' => "token #{subject.token}"
              }
            )
            .to_return(
              status: 200,
              body: JSON.dump(data),
              headers: {
                'Content-Type': 'application/json'
              }
            )
        end

        failed_responses.each do |name|
          stub_request(:get, "https://api.github.com/repos/#{name}/pulls?state=open")
            .with(
              headers: {
                'Authorization' => "token #{subject.token}"
              }
            )
            .to_return(
              status: 403,
              body: '{}',
              headers: {
                'Content-Type': 'application/json'
              }
            )
        end
        subject.execute!
      end

      it 'returns successfull pull requests' do
        expect(subject.pull_requests.size).to equal(4)
      end

      it 'records failed ones' do
        expect(subject.failed_repositories.sort).to eq(failed_responses.sort)
      end
    end
  end
end
