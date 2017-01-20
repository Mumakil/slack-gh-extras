# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::RepoList, type: :model do

  before do
    slack_test_configuration!
  end

  describe 'validations' do
    it 'works with add action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'repo_list add listname repo1')
      ).to be_valid
    end
    it 'works with remove action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'repo_list remove listname repo1')
      ).to be_valid
    end

    it 'works without action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'repo_list')
      ).to be_valid
    end

    it 'fails others' do
      expect(
        FactoryGirl.build(:slack_command, text: 'repo_list foobar')
      ).not_to be_valid
    end
  end
end
