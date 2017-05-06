Rails.application.routes.draw do

  devise_for :users, :controllers => {:registrations => "users/registrations"}

  # map.root :path_prefix => "users", :controller => "registrations", :action => "new"
  root :to => "home#index"

  resources :home

  # Require authentication for these pages.
  authenticate :user do
    resources :categories, only: [:index, :create, :update, :destroy]
    resources :browse, only: [:index, :create]
    resources :products, only: [:index, :create, :update, :destroy]
    resources :orders, only: [:index, :create]
    # Overriden get for orders in order to support product adding.
    get "orders/new/:product_id" => "orders#new"

    get "products/search" => "products#search"
    get "browse/search" => "browse#search"
  end
end
