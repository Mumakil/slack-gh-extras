# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::Token, type: :model do

  before do
    slack_test_configuration!
  end

  describe 'validations' do
    it 'works with set action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'token set foobar')
      ).to be_valid
    end
    it 'works with clear action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'token clear')
      ).to be_valid
    end

    it 'does not throw without action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'token')
      ).not_to be_valid
    end
  end

  describe '#process!' do

    context 'clear action' do

      let!(:existing_user) do
        FactoryGirl.create(:user, :with_slack_data, :with_github_data)
      end

      it 'clears existing user' do
        expect do
          FactoryGirl.build(
            :slack_command,
            text: 'token clear',
            user_id: existing_user.slack_id
          ).process!
        end.to change(User, :count).by(-1)
      end
      it 'does nothing if user does not exist' do
        expect do
          FactoryGirl.build(
            :slack_command,
            text: 'token clear'
          ).process!
        end.not_to change(User, :count)
      end
    end

    context 'set action' do

      let(:github_token) { 'new_github_token' }
      let(:github_id) { 100_000 + Random.rand(100_000) }
      let(:github_login) { 'github-login' }

      subject do
        FactoryGirl.build(
          :slack_command,
          :with_user,
          text: "token set #{github_token}"
        )
      end

      context 'with valid accesstoken' do

        before :each do
          allow(subject).to receive(:fetch_user!).with(github_token) do
            operation = Github::Operations::FetchUser.new(github_token)
            operation.instance_variable_set(
              :@user,
              id: github_id,
              login: github_login
            )
            operation.instance_variable_set(:@scopes, %w(repo))
            operation
          end
        end

        it 'creates a new user successfully' do
          expect do
            subject.process!
          end.to change(User, :count).by(1)
        end

        it 'updates existing user successfully' do
          u = FactoryGirl.create(:user, :with_slack_data, :with_github_data)
          subject.user_id = u.slack_id
          subject.user_name = u.slack_handle
          expect do
            subject.process!
          end.not_to change(User, :count)
          u.reload
          expect(u.github_token).to eq(github_token)
          # TODO investigate why github_id is string, not number
          expect(u.github_id.to_i).to equal(github_id)
          expect(u.github_handle).to eq(github_login)
        end

        it 'deletes existing github user' do
          u = FactoryGirl.create(
            :user,
            :with_slack_data,
            github_id: github_id,
            github_handle: github_login,
            github_token: github_token
          )
          expect do
            subject.process!
          end.not_to change(User, :count)
          expect do
            User.find(u.id)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with invalid accesstoken' do

        it 'fails gracefully when accesstoken is invalid' do
          allow(subject).to receive(:fetch_user!).with(github_token) do
            raise ::Github::ErrUnauthorized
          end
          expect do
            res = subject.process!
            expect(res).to match('Setting token failed')
          end.not_to change(User, :count)
        end

        it 'fails gracefully when scopes are not enough' do
          allow(subject).to receive(:fetch_user!).with(github_token) do
            operation = Github::Operations::FetchUser.new(github_token)
            operation.instance_variable_set(:@user, {})
            operation.instance_variable_set(:@scopes, [])
            operation
          end
          expect do
            res = subject.process!
            expect(res).to match('Setting token failed')
          end.not_to change(User, :count)
        end
      end

    end

  end

end
