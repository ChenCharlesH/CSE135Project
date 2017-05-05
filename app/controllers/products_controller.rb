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
    cat = params[:search_form][:category]

    if name.strip != "" || !cat.nil?
      @product_results = Product.where("LOWER(unique_name) LIKE ?", "%#{name}%")
      if !cat.nil?
        cat.each do |val|
          @product_results = @product_results.where(:category_id => val)
        end
      end
    else
      @product_results = Product.all
    end
    render :layout=>false
  end
end
