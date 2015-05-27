class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :login_as

  def current_user
    @current_user = User.find_by_id(session[:current_user_id])
  end

  def login_as(user)
    @current_user = user
    session[:current_user_id] = user.try(:id)
  end


end
