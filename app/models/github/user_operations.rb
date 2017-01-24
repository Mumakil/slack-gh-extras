# frozen_string_literal: true

module Github
  ##
  # User contains functionality related to fetching github users
  module UserOperations

    def fetch_user!(token)
      Operations::FetchUser.new(token).execute!
    end

    def valid_scopes?(scopes)
      REQUIRED_SCOPES & scopes == REQUIRED_SCOPES
    end
  end
end
