Rails.application.routes.draw do
  
  resources :photos do
    member do
      get :like
      get :unlike
    end
  end

  devise_for :users
  resources :users, only: [:show] do
    member do
      get :follow
      get :unfollow
    end
  end

  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
