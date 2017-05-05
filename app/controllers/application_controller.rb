class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authorize_owner
    return unless !current_user.owner?
    redirect_to root_path, alert: "This page is available to owners only."
  end
end
