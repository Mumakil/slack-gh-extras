# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is possible to save users' do
    expect do
      FactoryGirl.build(:user, :with_slack_data, :with_github_data).save!
    end.to change(User, :count).by(1)
  end
end
