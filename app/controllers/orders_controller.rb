# @Author: Hsien-Che Charles Chen
# @Date:   05-05-2017
# @Project: PA3
# @Last modified by:   Hsien-Che Charles Chen
# @Last modified time: 05-26-2017

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

      @product_numbers.append(v["product"])
      @quantity_numbers.append(v["quantity"])

      v[:user] = current_user.id
      v = v.permit(:user, :quantity, :product)

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
    render text: e.message
    return
    redirect_to "/orders", flash: {notice: "Failed to buy cart."}
  end

  # POST orders/
  # Function to insert new item into cart. Must
  # have proper post values.
  def create()
    params = create_params


    # check if purchase already exists.
    # Guranteed to only have one in db.
    @insert_cart = Cart.where(:user_id => current_user.id, :product_id => params["product_id"]).first
    if !@insert_cart.nil?
      @insert_cart.quantity = Integer(@insert_cart.quantity) + Integer(params["quantity"])
    else
      @insert_cart = Cart.new(params)
    end

    if @insert_cart.save
      redirect_to "/browse", flash: {notice: "Cart added successfully!"}
    else
      flash[:alert] = @insert_cart.errors.full_messages.to_sentence
      index()
      render action: :index
    end
  rescue => e
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
  rescue => e
    flash[:alert] = "Cart adding error."
    index()
    render action: :index
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
