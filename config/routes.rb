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
    resources :buynorder, only: [:index, :generate]
    resources :buynorder1, only: [:index, :generate]

    resources :similar, only: [:index]

    # Overriden get for orders in order to support product adding.
    get "orders/new/:product_id" => "orders#new"

    # AJAX related stuff.
    get "products/search" => "products#search"
    get "browse/search" => "browse#search"

    # Category stuff
    get "analytics" => "analytics#index"
    post "analytics/refresh" => "analytics#refresh"

    post "orders/confirm" => "orders#confirm"
    post "buynorder/generate"
    post "buynorder1/generate"
  end
end
