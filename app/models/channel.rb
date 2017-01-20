# frozen_string_literal: true

##
# Channel represents a slack channel and related data
class Channel < ApplicationRecord

  validates :slack_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :default_repositories, presence: true
end
