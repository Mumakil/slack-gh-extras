# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe 'slack', type: :request do

  before do
    slack_test_configuration!
  end

  describe 'POST /slack' do
    it 'fails without any args' do
      post '/slack'
      expect(response).not_to be_success
      expect(response.body).to include('Token is invalid')
      expect(response.body).to include('Team domain is not allowed')
      expect(response.body).to include('Command is not allowed')
      expect(response.body).to include("'' is not a known subcommand.")
    end

    it 'succeeds with help command' do
      data = FactoryGirl.build(:slack_command, text: 'help').as_json
      post '/slack', params: data
      expect(response).to be_success
      expect(response.body).to include('Here are the commands I know of')
    end
  end
end
