Rails.application.routes.draw do
  devise_for :users
  resources :direction

  namespace :admin do
    resources :schools
    resources :users
    root to: "dashboard#index"
  end
end
