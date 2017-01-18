# frozen_string_literal: true

##
# Users are mappings between slack and github identities
class User < ApplicationRecord
  validates :github_id, presence: true
  validates :github_handle, presence: true
  validates :github_token, presence: true

  validates :slack_id, presence: true
  validates :slack_handle, presence: true
end
