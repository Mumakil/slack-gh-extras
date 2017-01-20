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
    - token clear - clear GitHub access token
    - token set <accesstoken> - set GitHub access token
        eos
      end

    end
  end
end
