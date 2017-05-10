class CategoriesController < ApplicationController
  before_filter :authorize_owner

  # GET categories
  def index()
    @insert_category = Category.new
    @categories = current_user.categories.all
  end


  def create()
    params = create_param
    params[:user_id] = current_user.id
    @insert_category = Category.new(params)
    # Transaction already used within save function
    if @insert_category.save
      redirect_to "/categories", flash: {notice: "Insert successful!"}
    else
      flash[:alert] = @insert_category.errors.full_messages.to_sentence
      render action: :index
    end

    rescue
      flash[:alert] = "Category with Name already exists: " + params[:unique_name]
      @categories = current_user.categories.all
      render action: :index
  end

  # PUT categories
  def update()
    params = update_param

    value = current_user.categories.find(params[:id])
    if value.update_attributes(params)
      redirect_to "/categories", flash: {notice:"Update successful!"}
    else
      msg = "Data modification failure: " + value.errors.full_messages.to_sentence
      redirect_to "/categories", flash: {alert: msg}
    end
    rescue
      flash[:alert] = "Failure to update category."
      index()
      render action: :index
  end

  def destroy()
    params = delete_param
    # Check if associated products exist.
    cat = current_user.categories.find(params[:id])
    if !cat
      redirect_to "/categories", flash: {alert: "Data modification error."}
    elsif cat.products.size > 0
      redirect_to "/categories", flash: {alert: "Data modification error: Products exist."}
    else
      cat.destroy
      redirect_to "/categories", flash: {notice:"Delete successful!"}
    end
  end

  # Strong parameters
  def delete_param
    params.permit(:id)
  end

  def create_param
    params.require(:category).permit(:unique_name, :desc)
  end

  def update_param
    params.require(:id)
    final = params.require(:category).permit(:unique_name, :desc)
    final[:id] = params[:id]
    return final
  end
end
