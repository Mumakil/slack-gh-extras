# frozen_string_literal: true

##
# RepoList is a list containing multiple repositories
class RepoList < ApplicationRecord
  has_many :repositories, inverse_of: :repo_list

  validates :name, presence: true, uniqueness: true
end
