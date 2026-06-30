class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Pundit::Authorization
  include Pundit::ExpectedAttributeValues::Authorization

  helper_method :pundit_expected_attribute_values_for

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::ExpectedAttributeValues::UnexpectedValue, with: :unexpected_value

  private

  def user_not_authorized
    redirect_back fallback_location: root_path, alert: "Not authorized."
  end

  def unexpected_value(error)
    @error = error
    render "shared/unexpected_value", status: :unprocessable_entity
  end
end
