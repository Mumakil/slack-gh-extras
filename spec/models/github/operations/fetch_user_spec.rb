# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::Help, type: :model do

  describe '#execute!' do

    let(:login) { 'github-login' }
    let(:id) { 100_000 + Random.rand(100_000) }
    let(:github_user_data) do
      JSON.dump(
        id: id,
        login: login
      )
    end
    let(:valid_scopes) { 'repo' }
    let(:invalid_scopes) { '' }

    context 'with valid access token' do
      subject { Github::Operations::FetchUser.new('valid_access_token').execute! }

      before :each do
        stub_request(:get, 'https://api.github.com/user')
          .to_return(
            status: 200,
            body: github_user_data,
            headers: {
              'X-OAuth-Scopes': valid_scopes,
              'Content-Type': 'applicatin/json'
            }
          )
      end

      it 'fetches user' do
        expect(subject.user).not_to be_nil
        expect(subject.user.login).to eq(login)
        expect(subject.user.id).to eq(id)
      end
      it 'grabs scopes' do
        expect(subject.scopes).to eq(%w(repo))
      end
    end
  end
end
