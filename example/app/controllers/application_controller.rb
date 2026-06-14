class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Pundit::Authorization
  include Pundit::ExpectedAttributeValues::Authorization

  before_action :require_login

  helper_method :current_user, :pundit_expected_attribute_values_for

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::ExpectedAttributeValues::UnexpectedValue, with: :unexpected_value

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to root_path, alert: "Pick a user to sign in." unless current_user
  end

  def user_not_authorized
    redirect_back fallback_location: root_path, alert: "Not authorized."
  end

  # Demonstrates invalid_behavior = :raise. With the default :strip this never
  # fires (out-of-set values are silently dropped); flip the initializer to see
  # this 422 page instead.
  def unexpected_value(error)
    @error = error
    render "shared/unexpected_value", status: :unprocessable_entity
  end
end
