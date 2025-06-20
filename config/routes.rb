Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :schools
    resources :users
    root to: "dashboard#index"
  end

  root to: "home#index"
end
