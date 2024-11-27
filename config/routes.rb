Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  #
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Register page
  get '/register', to: 'users#new', as: 'register'

  # 3rd party login redirect
  get '/auth/:provider/callback', to: 'sessions#oauth_create'
  get '/auth/failure', to: redirect('/login')
  #get '/auth/:provider', to: proc { [404, {}, ['404 - OmniAuth provider not found!']] }, via: [:get, :post]


  resources :users
  resources :sessions, only: [ :new, :create, :destroy ]

  match "/signup", to: "users#new", via: :get, as: "signup"
  match "/login", to: "sessions#new", via: :get, as: "login"
  match "/logout", to: "sessions#destroy", via: :delete, as: "logout"

  root "application#index"

  resources :password_resets, only: [:new, :create, :edit, :update]
end
