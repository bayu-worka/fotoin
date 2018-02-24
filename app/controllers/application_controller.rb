class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_otp

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:phone, :address])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:phone, :address])
  end

  def authenticate_otp
    if user_signed_in? && !current_user.otp_status && !action_name.include?("otp") && !devise_controller?
      redirect_to otp_users_path
    end
  end
end
