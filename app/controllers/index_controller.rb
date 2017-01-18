# frozen_string_literal: true

##
# Dummy index controller to render a root
class IndexController < ApplicationController
  def index
    render json: { status: 'ok' }
  end
end
