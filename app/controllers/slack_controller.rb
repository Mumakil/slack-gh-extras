# frozen_string_literal: true

##
# Slack controller accepts incoming webhooks
class SlackController < ApplicationController

  def create
    command = Slack::Command.subclass_from_params(command_params)
    if command.valid?
      res = command.process!
      render status: 200, plain: res
    else
      render status: 400,
             plain: "There was a validation error with the command: \n" \
                    "#{command.errors.full_messages.join("\n")}"
    end
  rescue RuntimeError => e
    render status: 500,
           plain: "There was an error processing your command: \n#{e.message}"
  end

  private

  def command_params
    params.permit(:token, :team_domain,
                  :channel_name, :channel_id,
                  :user_id, :user_name,
                  :command, :text, :response_url)
  end
end
