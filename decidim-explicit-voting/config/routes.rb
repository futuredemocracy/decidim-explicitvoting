# frozen_string_literal: true

Decidim::Core::Engine.routes.draw do
  resources :explicit_voting, only: [] do
    resources :votes, only: [:create, :destroy]
  end
end 