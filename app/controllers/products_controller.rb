class ProductsController < ApplicationController
  before_filter :authorize_owner, only: [:destroy, :create, :update]

  # GET products
  def index()
    @product_results = Product.all
  end

  # POST products
  def create()

  end

  # AJAX ready call for search.
  # Note: JQuery ajax is not parsed for proper parameters.
  # Case insensitive
  def search()
    name = params[:search_form][:search_bar]
    name = name.downcase
    if name.strip != ""
      @product_results = Product.where("LOWER(unique_name) like ?", "%#{name}%")
    else
      @product_results = Product.all
    end
    render :layout=>false
  end
end
