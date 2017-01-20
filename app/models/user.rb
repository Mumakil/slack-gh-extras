# frozen_string_literal: true

##
# Users are mappings between slack and github identities
class User < ApplicationRecord
  validates :github_id, presence: true
  validates :github_handle, presence: true
  validates :github_token, presence: true

  validates :slack_id, presence: true
  validates :slack_handle, presence: true

  def self.from_slack_payload(payload)
    payload = payload.with_indifferent_access
    User.new(
      slack_id: payload[:user_id],
      slack_handle: payload[:user_name]
    )
  end

end
