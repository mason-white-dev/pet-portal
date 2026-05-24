class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Require user authentication for all actions by default.
  before_action :authenticate_user!

  # Ensure custom fields (like first_name, last_name) are permitted through Strong Parameters
  # whenever a Devise controller handles user registration or profile updates.
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Dynamically determine the layout to use based on the controller and user state.
  layout :layout_by_resource

  private

  # Use the "auth" layout for Devise controllers (like login/signup) when the user
  # is not yet authenticated. When they are logged in, use the "main" layout.
  def layout_by_resource
    if devise_controller? && !user_signed_in?
      "auth"
    else
      "main"
    end
  end

  # Custom parameter handler for Devise controllers.
  # This allows the "first_name" and "last_name" fields to be processed
  # along with the standard email/password fields during sign up and updates.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end
end
