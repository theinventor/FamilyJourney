# frozen_string_literal: true

class Rack::Attack
  # Use Rails cache store for throttling
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  # Throttle sign up attempts by IP address
  throttle("registrations/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  # Throttle sign in attempts by IP address
  throttle("logins/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle sign in attempts by email address
  throttle("logins/email", limit: 5, period: 1.minute) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle password reset requests by IP
  throttle("password_resets/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  # Throttle password reset requests by email
  throttle("password_resets/email", limit: 3, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    [
      429,
      { "Content-Type" => "text/html" },
      [ "Too many requests. Please try again later." ]
    ]
  end
end
