# frozen_string_literal: true

module Github
  module Operations

    ##
    # Fetches pull requests for a repo
    class FetchPullRequests < Github::Operation

      attr_reader :pull_requests, :repository_name

      def initialize(token, repository_name)
        super(token)
        @repository_name = repository_name
      end

      def execute!
        client.pull_requests(repository_name, state: 'open')
        self
      rescue Octokit::Unauthorized
        raise Github::ErrUnauthorized
      rescue Octokit::NotFound
        raise Github::ErrNotFound
      end
    end
  end
end
