# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is possible to save users' do
    expect do
      FactoryGirl.build(:user, :with_slack_data, :with_github_data).save!
    end.to change(User, :count).by(1)
  end

  it 'can create user from slack command data' do
    payload = FactoryGirl.build(:slack_command, :with_user)
    user = User.from_slack_payload(payload.as_json)
    expect(user.slack_id).to eq(payload.user_id)
    expect(user.slack_handle).to eq(payload.user_name)
  end
end
