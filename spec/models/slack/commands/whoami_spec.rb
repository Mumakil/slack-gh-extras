# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::Whoami, type: :model do

  before do
    slack_test_configuration!
  end

  describe '#process!' do

    subject do
      FactoryGirl.build(
        :slack_command,
        :with_user,
        text: 'whoami'
      )
    end

    context 'with existing user' do

      let!(:user) do
        FactoryGirl.create(
          :user,
          :with_github_data,
          slack_id: subject.user_id,
          slack_handle: subject.user_name
        )
      end

      context 'with valid access token' do
        before :each do
          allow(subject).to receive(:fetch_user!).with(user.github_token) do
            operation = Github::Operations::FetchUser.new(user.github_token)
            operation.instance_variable_set(
              :@user,
              id: user.github_id.to_i,
              login: user.github_handle
            )
            operation.instance_variable_set(:@scopes, %w(repo))
            operation
          end
        end

        it 'tells github identity' do
          expect(subject.process!).to match("You are `#{user.github_handle}`")
        end
      end

      context 'with invalid token' do
        it 'deletes user from db when access token is invalid' do
          allow(subject).to receive(:fetch_user!).with(user.github_token) do
            raise Github::ErrUnauthorized
          end
          expect do
            res = subject.process!
            expect(res).to match('need to set new access token')
          end.to change(User, :count).by(-1)
        end

        it 'deletes user from db when access token scopes are not enough' do
          allow(subject).to receive(:fetch_user!).with(user.github_token) do
            operation = Github::Operations::FetchUser.new(user.github_token)
            operation.instance_variable_set(
              :@user,
              id: user.github_id.to_i,
              login: user.github_handle
            )
            operation.instance_variable_set(:@scopes, %w())
            operation
          end
          expect do
            res = subject.process!
            expect(res).to match('need to set new access token')
          end.to change(User, :count).by(-1)
        end
      end
    end

    context 'without existing user' do
      it 'does nothing' do
        expect(subject.process!).to match("I don't know who you are")
      end
    end
  end

  #     context 'with valid accesstoken' do

  #       before :each do
  #         allow(subject).to receive(:fetch_user!).with(github_token) do
  #           operation = Github::Operations::FetchUser.new(github_token)
  #           operation.instance_variable_set(
  #             :@user,
  #             id: github_id,
  #             login: github_login
  #           )
  #           operation.instance_variable_set(:@scopes, %w(repo))
  #           operation
  #         end
  #       end

  #       it 'creates a new user successfully' do
  #         expect do
  #           subject.process!
  #         end.to change(User, :count).by(1)
  #       end

  #       it 'updates existing user successfully' do
  #         u = FactoryGirl.create(:user, :with_slack_data, :with_github_data)
  #         subject.user_id = u.slack_id
  #         subject.user_name = u.slack_handle
  #         expect do
  #           subject.process!
  #         end.not_to change(User, :count)
  #         u.reload
  #         expect(u.github_token).to eq(github_token)
  #         # TODO investigate why github_id is string, not number
  #         expect(u.github_id.to_i).to equal(github_id)
  #         expect(u.github_handle).to eq(github_login)
  #       end

  #       it 'deletes existing github user' do
  #         u = FactoryGirl.create(
  #           :user,
  #           :with_slack_data,
  #           github_id: github_id,
  #           github_handle: github_login,
  #           github_token: github_token
  #         )
  #         expect do
  #           subject.process!
  #         end.not_to change(User, :count)
  #         expect do
  #           User.find(u.id)
  #         end.to raise_error(ActiveRecord::RecordNotFound)
  #       end
  #     end

  #     context 'with invalid accesstoken' do

  #       it 'fails gracefully when accesstoken is invalid' do
  #         allow(subject).to receive(:fetch_user!).with(github_token) do
  #           raise ::Github::ErrUnauthorized
  #         end
  #         expect do
  #           res = subject.process!
  #           expect(res).to match('Setting token failed')
  #         end.not_to change(User, :count)
  #       end

  #       it 'fails gracefully when scopes are not enough' do
  #         allow(subject).to receive(:fetch_user!).with(github_token) do
  #           operation = Github::Operations::FetchUser.new(github_token)
  #           operation.instance_variable_set(:@user, {})
  #           operation.instance_variable_set(:@scopes, [])
  #           operation
  #         end
  #         expect do
  #           res = subject.process!
  #           expect(res).to match('Setting token failed')
  #         end.not_to change(User, :count)
  #       end
  #     end

  #   end

  # end

end
