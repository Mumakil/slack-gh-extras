# frozen_string_literal: true

module Github
  module Operations

    ##
    # Fetches pull requests for a repo
    class FetchPullRequests < Github::Operation

      attr_reader :pull_requests, :names, :repositories, :failed_repositories

      def initialize(token, names)
        super(token)
        @names = names
        @repositories = []
        @failed_repositories = []
      end

      def execute!
        repositories.each do |repository|
          fetch_one(repository)
        end
        self
      end

      def pull_requests
        @pull_requests.sort_by(&:created_at)
      end

      def failed_repositories?
        !failed_repositories.empty?
      end

      def fetch_one(repository_name)
        @repositories << client.pull_requests(repository_name, state: 'open')
      rescue Octokit::ClientError
        @failed_repositories << repository_name
      end
    end
  end
end
