class ApplicationController < ActionController::Base
  impersonates :user

  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception, prepend: true

  include SessionCurrentUser
  include ValidRequest

  rescue_from ActionView::MissingTemplate, with: :routing_error

  def not_found
    raise ActiveRecord::RecordNotFound, "Not Found"
  end

  def routing_error
    raise ActionController::RoutingError, "Routing Error"
  end

  def bad_request
    respond_to do |format|
      format.html do
        raise if Rails.env.development?

        render plain: "The request could not be understood (400).", status: :bad_request
      end

      format.json do
        render json: { error: I18n.t("application_controller.bad_request") }, status: :bad_request
      end
    end
  end

  def authenticate_user
    return false unless current_user

    true
  end

  def authenticate_admin!(alert_message: nil)
    redirect_to new_user_session_path, alert: alert_message unless current_user&.admin?
  end

  def after_sign_in_path_for(resource)
    resource.paying_customer? ? dashboard_index_path : subscribe_index_path # point these wherever you want
  end

  def maybe_skip_onboarding
    redirect_to dashboard_index_path, notice: "You're already subscribed" if current_user.finished_onboarding?
  end

  def anonymous_user
    User.new(ip_address: request.env["HTTP_FASTLY_CLIENT_IP"] || request.remote_ip)
  end

  # whitelist extra User model params by uncommenting below and adding User attrs as keys
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :name, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :name, :email, :password_confirmation, :current_password])
    devise_parameter_sanitizer.permit(:accent_invitation, keys: [:name])
  end
end
