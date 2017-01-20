# frozen_string_literal: true

require 'slack-notifier'

##
# Notifies a channel when defaults are changed
class SlackNotifierJob < ApplicationJob

  def perform(url, message)
    notifier(url).post(text: message, response_type: 'in_channel')
  end

  def notifier(url)
    Slack::Notifier.new(url)
  end
end
