# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Index', type: :request do
  describe 'GET /' do
    it 'renders dummy index' do
      get '/'
      expect(response).to have_http_status(200)
    end
  end
end
