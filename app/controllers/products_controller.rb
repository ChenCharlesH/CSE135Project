class ProductsController < ApplicationController
  before_filter :authorize_owner

  # GET products
  def index()
    @insert_product = Product.new
    @product_results = Product.all
  end

  # POST products
  def create()
    params = create_params

    @insert_product = Product.new(params)
    if @insert_product.save
      redirect_to "/products", flash: {notice: "Insert successful!"}
    else
      flash[:alert] = @insert_product.errors.full_messages.to_sentence
      render action: :index
    end
    rescue
      flash[:alert] = "Failure to insert new product."
      @product_results = Product.all
      render action: :index
  end

  # PUT products/:id
  def update()
    params = update_params

    value = Product.find(params[:id])
    if value.update_attributes(params)
      redirect_to "/products", flash: {notice:"Update successful!"}
    else
      msg = "Update Failure: " + value.errors,full_messages.to_sentence
      redirect_to "/products", flash: {alert: msg}
    end
    rescue
      flash[:alert] = "Failure to update product."
      index()
      render action: :index
  end

  def destroy()
    params = delete_params

    prod = Product.find(params[:id])
    if !prod
      redirect_to "/products", flash: {alert: "Delete failure."}
    else
      prod.destroy
      redirect_to "/products", flash: {notice: "Delete successful!"}
    end

  rescue
      redirect_to "/products", flash: {alert: "Delete failure."}
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

  # Strong parameters
  def create_params
    params.require(:product).permit(:unique_name, :sku, :price, :category_id)
  end

  def delete_params
    params.permit(:id)
  end

  def update_params
    params.require(:id)
    final = params.require(:products).permit(:unique_name, :sku,:price, :category_id)
    final[:id] = params[:id]
    return final
  end
end
