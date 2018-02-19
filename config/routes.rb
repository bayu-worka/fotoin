Rails.application.routes.draw do
  resources :moments
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  mount Sidekiq::Web => '/sidekiq'
  resources :photos, only: [:show] do
    member do
      get :like
      get :unlike
      post "comments", to: "comments#create", as: :comments
      # post "comments/:comment_id", to: "comments#reply", as: :comment_reply
      delete "comment/:comment_id", to: "comments#destroy", as: :comment
    end
  end
  
  devise_for :users
  resources :users, only: [:show] do
    collection do
      get :gallery
      get :otp
      get :request_otp
      post :validate_otp
      get :profile
    end

    member do
      get :follow
      get :unfollow
    end
  end

  namespace :api do
    namespace :v1 do
      resources :moments, except: [:new, :edit]

      resources :photos, only: [:show] do
        member do
          get :like
          get :unlike
          post "comments", as: :comments
          delete "comment/:comment_id", to: "photos#destroy", as: :comment
          get :root_comments
          get :check_like_status
        end
      end

      resources :users, only: [:show] do
        collection do
          post :sign_up
          post :sign_in
          post :forgot_password
          get :gallery
          get :profile
          get :request_otp
          post :validate_otp
          post :check_token
          get :timeline
        end

        member do
          get :moments
          get :follow
          get :unfollow
          get :check_follow_status
        end
      end
    end
  end

  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
