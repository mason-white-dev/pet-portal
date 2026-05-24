class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Require user authentication for all actions by default.
  before_action :authenticate_user!

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Dynamically determine the layout to use based on the controller and user state.
  layout :layout_by_resource

  private

  # Use the "auth" layout for Devise controllers (like login/signup) when the user
  # is not yet authenticated. Otherwise, use the standard "application" layout.
  def layout_by_resource
    if devise_controller? && !user_signed_in?
      "auth"
    else
      "application"
    end
  end
end
