# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Github::Operations::FetchUser, type: :model do

  describe '#execute!' do

    let(:login) { 'github-login' }
    let(:id) { 100_000 + Random.rand(100_000) }
    let(:github_user_data) do
      JSON.dump(
        id: id,
        login: login
      )
    end
    let(:scopes) { 'repo,user' }
    subject { FactoryGirl.build(:github_user_operation) }

    context 'with valid access token' do

      before :each do
        stub_request(:get, 'https://api.github.com/user')
          .with(
            headers: {
              'Authorization' => "token #{subject.token}"
            }
          )
          .to_return(
            status: 200,
            body: github_user_data,
            headers: {
              'X-OAuth-Scopes': scopes,
              'Content-Type': 'application/json'
            }
          )
        subject.execute!
      end

      it 'fetches user' do
        expect(subject.user).not_to be_nil
        expect(subject.user.login).to eq(login)
        expect(subject.user.id).to eq(id)
      end

      it 'grabs scopes' do
        expect(subject.scopes).to eq(%w(repo user))
      end
    end

    context 'with invalid access token' do

      before :each do
        stub_request(:get, 'https://api.github.com/user')
          .with(
            headers: {
              'Authorization' => "token #{subject.token}"
            }
          )
          .to_return(
            status: 401,
            body: '{}',
            headers: {
              'Content-Type': 'application/json'
            }
          )
      end

      it 'raises correct error' do
        expect do
          subject.execute!
        end.to raise_error(Github::Error)
      end
    end
  end
end
