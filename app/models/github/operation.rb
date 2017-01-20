# frozen_string_literal: true

module Github

  ##
  # Operation is a superclass of all GitHub operations
  class Operation

    attr_reader :accesstoken

    def initialize(accesstoken)
      @accesstoken = accesstoken
    end

    def client
      @client ||= Octokit::Client.new(access_token: accesstoken)
      @client
    end
  end
end
