class OrdersController < ApplicationController
  # GET orders/
  # Basic function to display cart
  def index()
    @carts = current_user.carts.all
    # Generate Products
    @product_id = @carts.map{|h| h.id }
    @products = Product.where("id IN (?)", @product_id)
  end

  # POST orders/confirm
  # Function to parse saving to products.
  def confirm()
    params = conf_params

    @product_numbers = []
    @quantity_numbers = []
    @credit_card = 0

    params.each do |k, v|
      if k == "credit_card"
        @credit_card = v
        next
      end

      @product_numbers.append(v["product_id"])
      @quantity_numbers.append(v["quantity"])

      v[:user_id] = current_user.id
      v = v.permit(:user_id, :quantity, :product_id)
      @insert_purchase = Purchase.new(v)
      if @insert_purchase.save
        next
      else
        flash[:alert] = @insert_purchase.errors.full_messages.to_sentence
        index()
        render action: :index
      end
    end

    # Potentially dangerous without checking user id
    Cart.where(:user_id => current_user.id).destroy_all

  rescue => e
    flash[:alert] = "Failed to buy cart."
    index()
    render action: :index
  end

  # POST orders/
  # Function to insert new item into cart. Must
  # have proper post values.
  def create()
    params = create_params

    @insert_cart = Cart.new(params)
    if @insert_cart.save
      redirect_to "/browse", flash: {notice: "Cart added successfully!"}
    else
      flash[:alert] = @insert_cart.errors.full_messages.to_sentence
      index()
      render action: :index
    end
    rescue
      flash[:alert] = "Cart adding error."
      index()
      render action: :index
  end

  # POST orders/:product_id
  # Function to add a product to cart.
  def new()
    params = new_params
    @insert_product_id = params
    @insert_product = Product.find(@insert_product_id)
    # Get data for cart info.
    index()
  end

  # Strong Parameters
  def conf_params
    params.require(:products)
  end

  def new_params
    params.require(:product_id)
  end

  def create_params
    params.require(:cart).permit(:user_id, :product_id, :quantity)
  end
end
