# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Command, type: :model do

  before do
    slack_test_configuration!
  end

  context 'validation' do
    it 'is not valid if empty' do
      expect(Slack::Command.new).not_to be_valid
    end

    it 'is valid with correct domain, command and token' do
      expect(
        Slack::Command.new(
          team_domain: Slack::Configuration.team_domain,
          token: Slack::Configuration.command_token,
          command: Slack::Configuration.command,
          text: 'help'
        )
      ).to be_valid
    end

    it 'has valid default factory' do
      expect(FactoryGirl.build(:slack_command)).to be_valid
    end
  end

  context '.subclass_from_params' do
    it 'knows help command' do
      expect(
        Slack::Command.subclass_from_params(text: 'help')
      ).to be_instance_of(Slack::Commands::Help)
    end

    it 'returns default class if unknown' do
      expect(
        Slack::Command.subclass_from_params({})
      ).to be_instance_of(Slack::Command)
    end
  end
end
