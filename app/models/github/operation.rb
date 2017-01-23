# frozen_string_literal: true

module Github

  ##
  # Operation is a superclass of all GitHub operations
  class Operation

    attr_reader :token

    def initialize(token)
      @token = token
    end

    def client
      @client ||= Octokit::Client.new(access_token: token)
      @client
    end
  end
end
