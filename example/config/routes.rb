Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Pick a seeded user to sign in as, then sign out to switch users.
  root "sessions#new"
  resource :session, only: [:create, :destroy]

  resources :posts
end
