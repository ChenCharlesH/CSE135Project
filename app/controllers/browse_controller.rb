class BrowseController < ApplicationController

  # GET browse
  def index()
    @product_results = Product.all
  end

  # POST browse
  def create()

  end

  # AJAX ready call for search.
  # Note: JQuery ajax is not parsed for proper parameters.
  # Case insensitive
  def search()
    name = params[:search_form][:search_bar]
    name = name.downcase
    cat = params[:search_form][:category]

    if (name.strip != "" || !cat.nil?)
      @product_results = Product.where("LOWER(unique_name) LIKE ?", "%#{name}%")
      if !cat.nil? && cat.to_i >= 0
          @product_results = @product_results.where(:category_id => cat)
      end
    else
      @product_results = Product.all
    end
    render :layout=>false
  end
end
