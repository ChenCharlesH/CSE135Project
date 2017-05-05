Rails.application.routes.draw do

  devise_for :users, :controllers => {:registrations => "users/registrations"}

  # map.root :path_prefix => "users", :controller => "registrations", :action => "new"
  root :to => "home#index"

  resources :home

  # Require authentication for these pages.
  authenticate :user do
    resources :categories, only: [:index, :create, :update, :destroy]
    resources :products, only: [:index, :create, :update, :destroy]
    get "products/search" => "products#search"
  end
end
