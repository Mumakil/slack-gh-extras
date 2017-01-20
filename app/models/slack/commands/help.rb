# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Help responds with help text
    class Help < Slack::Command

      def process!
        <<-eos
Here are the commands I know of:
    - help - print this help
    - accesstoken <access token>|clear - set or clear GitHub access token
        eos
      end

    end
  end
end
