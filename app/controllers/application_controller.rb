class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Require user authentication through Devise for all actions by default.
  before_action :authenticate_user!

  # Dynamically determine the layout to use based on the controller and user state (see below method).
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
end
