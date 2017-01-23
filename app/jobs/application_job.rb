# frozen_string_literal: true

##
# Default job
class ApplicationJob < ActiveJob::Base
  include SuckerPunch::Job

  def with_connection_pool
    ActiveRecord::Base.connection_pool.with_connection(&block)
  end

  def slack_notifier(url)
    Slack::Notifier.new(url)
  end
end
