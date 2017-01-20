# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Command, type: :model do

  before do
    slack_test_configuration!
  end

  describe 'validation' do
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

  describe '.subclass_from_params' do
    it 'knows help command' do
      expect(
        Slack::Command.subclass_from_params(text: 'help')
      ).to be_instance_of(Slack::Commands::Help)
    end

    it 'knows accesstoken command' do
      expect(
        Slack::Command.subclass_from_params(text: 'token clear')
      ).to be_instance_of(Slack::Commands::Token)
    end

    it 'knows whoami command' do
      expect(
        Slack::Command.subclass_from_params(text: 'whoami')
      ).to be_instance_of(Slack::Commands::Whoami)
    end

    it 'knows repo_list command' do
      expect(
        Slack::Command.subclass_from_params(text: 'repo_lists')
      ).to be_instance_of(Slack::Commands::RepoLists)
    end

    it 'returns default class if unknown' do
      expect(
        Slack::Command.subclass_from_params({})
      ).to be_instance_of(Slack::Command)
    end
  end

  describe '.arguments' do
    it 'removes the subcommand' do
      expect(
        Slack::Command.new(text: 'accesstoken clear').arguments
      ).to eq('clear')
    end

    it 'can handle empty arguments' do
      expect(
        Slack::Command.new(text: 'help').arguments
      ).to eq('')
    end

    it 'can handle whitespace' do
      expect(
        Slack::Command.new(text: '  accesstoken   set  foobar ').arguments
      ).to eq('set  foobar')
    end
  end

  describe '.tokenized_arguments' do
    it 'returns empty array without arguments' do
      expect(
        Slack::Command.new(text: 'help').tokenized_arguments
      ).to eq([])
    end

    it 'returns tokenized arguments' do
      expect(
        Slack::Command.new(text: 'accesstoken clear').tokenized_arguments
      ).to eq(['clear'])
    end

    it 'can handle whitespace' do
      expect(
        Slack::Command.new(text: '  accesstoken   set  foobar ').tokenized_arguments
      ).to eq(%w(set foobar))
    end
  end
end
