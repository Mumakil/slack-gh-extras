# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is possible to save users' do
    expect do
      FactoryGirl.build(:user).save!
    end.to change(User, :count).by(1)
  end

  describe '::from_slack_payload' do
    it 'can create user from slack command data' do
      payload = FactoryGirl.build(:slack_command)
      user = User.from_slack_payload(payload.as_json)
      expect(user.slack_id).to eq(payload.user_id)
      expect(user.slack_handle).to eq(payload.user_name)
    end
  end

  describe '::find_or_initialize_by_slack_payload' do

    context 'without existing user' do
      let(:payload) { FactoryGirl.build(:slack_command) }
      subject { User.find_or_initialize_by_slack_payload(payload.as_json) }

      it { is_expected.to be_new_record }

      it 'populates user fields' do
        expect(subject.slack_id).to eq(payload.user_id)
        expect(subject.slack_handle).to eq(payload.user_name)
      end

    end

    context 'with existing user' do
      let(:existing_user) do
        FactoryGirl.create(:user)
      end
      let(:payload) do
        FactoryGirl.build(
          :slack_command,
          user_id: existing_user.slack_id,
          user_name: existing_user.slack_handle
        )
      end
      subject { User.find_or_initialize_by_slack_payload(payload.as_json) }

      it { is_expected.not_to be_new_record }

      it 'returns the existing user' do
        expect(subject.id).to equal(existing_user.id)
      end
    end
  end
end
