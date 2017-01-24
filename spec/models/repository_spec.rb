# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Repository, type: :model do

  let(:repo_list) { FactoryGirl.create(:repo_list) }

  describe 'validations' do
    it 'is not valid without name and repository' do
      expect(Repository.new).not_to be_valid
    end
    it 'is valid with name and repo list' do
      expect(Repository.new(name: 'org/repo', repo_list: repo_list)).to be_valid
    end
    it 'is not valid with bogus name' do
      expect(Repository.new(name: 'repo', repo_list: repo_list)).not_to be_valid
    end
    it 'has valid default factory' do
      expect(FactoryGirl.build(:repository)).to be_valid
    end
  end
end
