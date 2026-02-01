Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Dashboard requires authentication
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Kid profile
  get "profile", to: "profiles#show", as: :profile

  # Prizes for kids
  resources :prizes, only: [:index, :show]

  # Submissions for kids
  resources :submissions, only: [:show]
  resources :badges, only: [:show] do
    resources :submissions, only: [:new, :create]
  end

  # Challenge completions for kids
  resources :challenge_completions, only: [:new, :create]

  # Redemptions for kids
  resources :redemptions, only: [:index, :new, :create, :show]


  # Admin namespace for parents
  namespace :admin do
    resources :groups do
      member do
        post :add_member
        post :remove_member
      end
    end

    resources :badge_categories do
      member do
        post :move_up
        post :move_down
      end
    end

    resources :badges do
      member do
        post :publish
        post :unpublish
      end
    end

    resources :reviews, only: [:index, :show] do
      member do
        post :approve
        post :deny
      end
    end

    resources :prizes

    resources :redemptions, only: [:index, :show] do
      member do
        post :approve
        post :deny
      end
    end
  end

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check

  # Authenticated users go to dashboard, visitors see landing page
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  root to: "home#index"
end
