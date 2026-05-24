Cloudinary.config do |config|
  case Rails.env
  when "production"
    # Use 'fetch' to force crash in PRD. Prevents app deploying if API keys are missing.
    config.cloud_name = ENV.fetch("CLOUDINARY_CLOUD_NAME")
    config.api_key    = ENV.fetch("CLOUDINARY_API_KEY")
    config.api_secret = ENV.fetch("CLOUDINARY_API_SECRET")
  when "test"
    # Use dummy values to force network errors if a test tries to hit the real API
    config.cloud_name = "mock-test-cloud"
    config.api_key    = "mock-key"
    config.api_secret = "mock-secret"
  when "development"
    # Use 'fetch' to force crash in DEv. Prevents app deploying if API keys are missing
    # Ensures realistic development environment.
    config.cloud_name = ENV.fetch("CLOUDINARY_CLOUD_NAME")
    config.api_key    = ENV.fetch("CLOUDINARY_API_KEY")
    config.api_secret = ENV.fetch("CLOUDINARY_API_SECRET")
  end

  config.cdn_subdomain = true
end
