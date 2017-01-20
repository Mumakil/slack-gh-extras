# frozen_string_literal: true

##
# Repository is a single github repository
class Repository < ApplicationRecord
  belongs_to :repo_list, inverse_of: :repositories

  validates :repo_list, presence: true
  validates :name, presence: true, format: {
    with: %r{\A[^\s]+\/[^\s]+\Z},
    message: 'does not look like a repository name.'
  }, uniqueness: {
    scope: :repo_list_id,
    message: 'is already part of list'
  }
end
