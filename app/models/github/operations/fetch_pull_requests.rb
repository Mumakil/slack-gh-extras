# frozen_string_literal: true

module Github
  module Operations

    ##
    # Fetches pull requests for a repo
    class FetchPullRequests < Github::Operation

      attr_accessor :pull_requests, :names, :failed_repositories

      def initialize(token, names)
        super(token)
        @names = names
        @pull_requests = []
        @failed_repositories = []
      end

      def execute!
        names.each do |repository|
          fetch_one(repository)
        end
        self
      end

      def pull_requests
        @pull_requests.flatten.sort_by(&:created_at)
      end

      def failed_repositories?
        !@failed_repositories.empty?
      end

      def fetch_one(repository_name)
        @pull_requests << client.pull_requests(repository_name, state: 'open')
      rescue Octokit::ClientError
        @failed_repositories << repository_name
      end
    end
  end
end
