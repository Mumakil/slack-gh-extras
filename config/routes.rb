# frozen_string_literal: true

Rails.application.routes.draw do
  resources :slack, only: [:create]

  root to: 'index#index'
end
