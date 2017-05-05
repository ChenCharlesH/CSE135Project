class CategoriesController < ApplicationController
  before_filter :authorize_owner

  # GET categories
  def index()

  end

  # PUT categories
  def update()
    params = update_param

    if !current_user
      redirect_to "/categories", flash: {alert: "Data modification error."}
    end

    value = current_user.categories.find(params[:id])
    if value.update_attributes(params)
      redirect_to "/categories", flash: {notice:"Update successful!"}
    else
      msg = "Data modification failure: " + value.errors.full_messages.to_sentence
      redirect_to "/categories", flash: {alert: msg}
    end

  else
  end

  def destroy()
    params = delete_param
    # Check if associated products exist.
    cat = current_user.categories.find(params[:id])
    if !cat
      redirect_to "/categories", flash: {alert: "Data modification error."}
    elsif cat.size > 0
      redirect_to "/categories", flash: {alert: "Data modification error: Products exist."}
    else
      cat.destroy
      redirect_to "/categories", flash: {notice:"Delete successful!"}
    end
  end

  # Strong parameters
  def delete_param
    params.require(:id)
  end

  def update_param
    params.require(:id)
    final = params.require(:category).permit(:unique_name, :desc)
    final[:id] = params[:id]
    return final
  end
end
