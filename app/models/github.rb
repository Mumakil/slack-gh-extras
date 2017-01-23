# frozen_string_literal: true

module Github

  REQUIRED_SCOPES = %w(repo).freeze

  class ErrUnauthorized < RuntimeError; end
  class ErrNotFound < RuntimeError; end
end
