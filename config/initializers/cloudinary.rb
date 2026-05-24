Cloudinary.config do |config|
  case Rails.env
  when "test"
    # Dummy values so the test suite never needs real keys or hits the live API
    config.cloud_name = "mock-test-cloud"
    config.api_key    = "mock-key"
    config.api_secret = "mock-secret"
  else
    # development & production both pull from encrypted credentials.
    # .fetch preserves your fail-fast intent: boot crashes loudly if a key is missing.
    creds = Rails.application.credentials.cloudinary
    config.cloud_name = creds.fetch(:cloud_name)
    config.api_key    = creds.fetch(:api_key)
    config.api_secret = creds.fetch(:api_secret)
  end

  config.cdn_subdomain = true
end
