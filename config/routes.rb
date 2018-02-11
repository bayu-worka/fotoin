Rails.application.routes.draw do

  resources :photos do
    member do
      get :like
      get :unlike
      post "comments", to: "comments#create", as: :comments
      post "comments/:comment_id", to: "comments#reply", as: :comment_reply
      delete "comment", to: "comments#destroy", as: :comment
    end
  end
  
  devise_for :users
  resources :users, only: [:show] do
    collection do
      get :gallery
      get :otp
      get :request_otp
      post :validate_otp
    end

    member do
      get :follow
      get :unfollow
    end
  end

  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
