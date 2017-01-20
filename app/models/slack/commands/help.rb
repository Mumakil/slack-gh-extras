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
    - whoami - check who you are in GitHub according to your saved access token
    - repo_list - show what repository lists you have
    - repo_list add <repo1, repo2...> - add repositories to a list
    - repo_list remove <repo1, repo2...> - remove repositories from a list
        eos
      end

    end
  end
end
