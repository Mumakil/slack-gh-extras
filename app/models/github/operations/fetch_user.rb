# frozen_string_literal: true

module Github
  module Operations

    ##
    # Fetch user fetches the current user data from github
    class FetchUser < Github::Operation

      attr_reader :scopes, :user

      def execute!
        @user = client.user
        @scopes = client.last_response.headers['x-oauth-scopes'].split(',')
        self
      end
    end
  end
end
