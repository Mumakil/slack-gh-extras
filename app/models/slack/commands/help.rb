# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Help responds with help text
    class Help < Slack::Command

      def process!
        <<-eos
Here are the commands I know of:
    - `help` - print this help
    - `token clear` - clear GitHub access token
    - `token set <accesstoken>` - set GitHub access token
    - `whoami` - check who you are in GitHub according to your saved access token
    - `repo_lists` - show what repository lists you have
    - `repo_lists add <list_name> <org/repo1, org/repo2...>` - add repositories to a list
    - `repo_lists remove <list_name> <org/repo1, org/repo2...>` - remove repositories from a list

Note that when referencing repositories, you should always use the full name with organization, eg. `organization/repository-name`.
        eos
      end

    end
  end
end
