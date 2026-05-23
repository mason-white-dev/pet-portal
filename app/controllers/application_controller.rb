class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Require user authentication for all actions by default.
  before_action :authenticate_user!

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :layout_by_resource

  private
  def layout_by_resource
    if devise_controller? && !user_signed_in?
      "auth"
    else
      "application"
    end
  end

end
