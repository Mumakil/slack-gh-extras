# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepoList, type: :model do

  describe 'validations' do

    it 'is not valid without name' do
      expect(RepoList.new).not_to be_valid
    end
    it 'is valid with name' do
      expect(RepoList.new(name: 'my list')).to be_valid
    end
    it 'has valid default factory' do
      expect(FactoryGirl.build(:repo_list)).to be_valid
    end
  end
end
