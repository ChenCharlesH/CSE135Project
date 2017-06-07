class BuynorderController < ApplicationController
  before_filter :authorize_owner

  def index()

  end

  # Generate N orders
  def generate()
    # Grab 10 random users
    @random_users = User.order("RANDOM()").limit(10)

    # For each user, purchase 5 random products of quantity 1-10
    @random_users.each do |u|
      @random_prods = Product.order("RANDOM()").limit(5)

      @random_prods.each do |r|
        rand_quantity = rand(1..10)
        @neworder = Purchase.new(user: u.id, product: r.id, quantity: rand_quantity)

        # Attempt to commit the new order
        if @neworder.save
          next
        else
          flash[:alert] = @neworder.errors.full_messages.to_sentence
          render action: :index
        end #end if
      end #end products for each
    end #end users for each

    # If all went well, redirect and report
    redirect_to "/buynorder", flash: {notice:"Generated 10 orders!"}

  end #end generate
end #end class
