# frozen_string_literal: true

module Slack
  module Commands
    ##
    # Help responds with help text
    class Help < Slack::Command

      def process!
        <<-eos
Here are the commands I know of:
    - `help` - Print this help.
    - `token clear` - Clear your GitHub access token.
    - `token set <accesstoken>` - Set your GitHub access token.
    - `whoami` - Check who you are in GitHub according to your saved access token.
    - `list` - Print all repository lists.
    - `list add <list_name> <org/repo1> <org/repo2>...` - Add repositories to a list. Creates a new one if it does not exist.
    - `list remove <list_name> <org/repo1> <org/repo2>...` - Remove repositories from a list. If a list becomes empty it will be deleted.
    - `default` - Print default repositories for this channel.
    - `default set <list_name|org/repo1> <list_name2|org/repo2>...` - Set new default set of repositories for this channel.
    - `default clear` - Clear the defaults for this channel.
    - `prs` - fetch open pull requests for default repositories in this channel.
    - `prs <list_name|org/repo1>...` - Fetch open pull requests for the repositories in arguments / provided repository lists.

Note that when referencing repositories, you should always use the full name with organization, eg. `organization/repository-name`.

I will perform every GitHub operation with your personal access token.
        eos
      end

    end
  end
end
