# frozen_string_literal: true

module Github

  REQUIRED_SCOPES = %w(repo).freeze

  class Error < RuntimeError; end
end
