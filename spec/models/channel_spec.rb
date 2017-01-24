# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Channel, type: :model do
  it 'has valid default factory' do
    expect(FactoryGirl.build(:channel)).to be_valid
  end
end
