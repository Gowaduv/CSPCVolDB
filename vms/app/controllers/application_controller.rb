class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Fixes cancan ForbiddenAttributesError when creating new entries
  #before_filter do
  #  resource = controller_name.singularize.to_sym
  #  method = "#{resource}_params"
  #  params[resource] &&= send(method) if respond_to?(method,true)
  #end
    
  protected

  def check_user_match(user_id)
    if (current_user.id != user_id.to_i)
      Rails.logger.debug("Attempted hacking? #{current_user} trying to sign up #{offer_params.inspect}")
      redirect_to listing_path
      return false
    else
      return true
    end
    
  end    

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.error "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_path, :alert => exception.message
  end
    
  def access_denied(exception)
    Rails.logger.error "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_path, :alert => exception.message
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :member_number, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :member_number, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :member_number, :password, :password_confirmation, :current_password) }
  end
  
  def authenticate_admin_user!
    Rails.logger.debug("current user try admin #{current_user.try(:admin?)}")
    raise SecurityError unless current_user.try(:admin?)
  end
  
  rescue_from SecurityError do |exception|
    Rails.logger.debug("SecurityError redirected to root #{exception.inspect}")
    redirect_to root_url
  end
  
 # rescue_from StandardError do |exception|
 #   Rails.logger.debug("StandardError #{exception.inspect}")
 #   redirect_to root_url
 # end
end
