# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::Help, type: :model do

  before do
    slack_test_configuration!
  end

  subject { FactoryGirl.build(:slack_command, text: 'help') }

  describe '#process!' do
    it 'prints help' do
      expect(subject.process!).to include('Here are the commands I know of')
    end
  end
end
