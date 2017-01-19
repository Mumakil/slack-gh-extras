# frozen_string_literal: true

module Slack
  ##
  # Command represents an incoming slack /command
  class Command
    include ActiveModel::Model

    attr_accessor :token, :team_domain, :channel_name, :user_id, :user_name,
                  :command, :text, :response_url

    validates_each :token do |record, attr, value|
      unless value == Slack::Configuration.command_token
        record.errors.add(attr, 'is invalid')
      end
    end

    validates_each :team_domain do |record, attr, value|
      unless value == Slack::Configuration.team_domain
        record.errors.add(attr, 'is not allowed')
      end
    end

    validates_each :command do |record, attr, value|
      unless value == Slack::Configuration.command
        record.errors.add(attr, 'is wrong')
      end
    end


    def process!

    end

  end

end
