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
        text: 'whoami'
      )
    end

    context 'with existing user' do

      let!(:user) do
        FactoryGirl.create(
          :user,
          slack_id: subject.user_id,
          slack_handle: subject.user_name
        )
      end
      let(:user_operation) do
        FactoryGirl.build(
          :github_user_operation,
          :with_response,
          github_id: user.github_id.to_i,
          github_handle: user.github_handle,
          scopes: ['repo']
        )
      end

      context 'with valid access token' do
        before :each do
          allow(subject).to receive(:fetch_user!).with(user.github_token) do
            user_operation
          end
        end

        it 'tells github identity' do
          expect(subject.process!).to match("You are `#{user.github_handle}`")
        end
      end

      context 'with invalid token' do
        it 'deletes user from db when access token is invalid' do
          allow(subject).to receive(:fetch_user!).with(user.github_token) do
            raise Github::Error
          end
          expect do
            res = subject.process!
            expect(res).to match('need to set new access token')
          end.to change(User, :count).by(-1)
        end

        it 'deletes user from db when access token scopes are not enough' do
          user_operation.scopes = []
          allow(subject).to receive(:fetch_user!).with(user.github_token) do
            user_operation
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
end
