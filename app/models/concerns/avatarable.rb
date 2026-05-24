# The Avatarable concern DRYs up the Active Storage profile image logic.
# By including this module in a model (e.g., Pet, User), it automatically
# attaches the `:avatar_image` relationship to that model, allowing it to
# process and store cloud-based profile photos seamlessly.
module Avatarable
  extend ActiveSupport::Concern

  included do
    # Defines the Active Storage relationship. This allows us to call
    # `@record.avatar_image.attach(params[:avatar_image])` in the controllers.
    has_one_attached :avatar_image

    validate :acceptable_avatar_image
  end

  private

  # Custom validation method to secure file uploads.
  # Active Storage does not have built-in file validations, so we must
  # manually inspect the attached blob's byte size and content type.
  def acceptable_avatar_image
    return unless avatar_image.attached?

    # 1. Enforce maximum file size (5MB) to prevent storage abuse
    unless avatar_image.blob.byte_size <= 5.megabytes
      errors.add(:avatar_image, "is too big (must be under 5MB)")
    end

    # 2. Enforce allowed MIME types to prevent malicious non-image file uploads
    acceptable_types = [ "image/jpeg", "image/png", "image/gif", "image/webp" ]
    unless acceptable_types.include?(avatar_image.content_type)
      errors.add(:avatar_image, "must be a valid image format (JPEG, PNG, GIF, WEBP)")
    end
  end
end
