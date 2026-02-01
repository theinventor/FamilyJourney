require "test_helper"

class RateLimitingTest < ActionDispatch::IntegrationTest
  setup do
    # Use a fresh cache store for each test to ensure isolation
    @cache = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.cache.store = @cache
    Rack::Attack.enabled = true
  end

  teardown do
    Rack::Attack.reset!
  end

  # Registration throttling tests
  test "allows registration attempts within limit" do
    5.times do |i|
      post "/users", params: {
        user: {
          email: "newuser#{i}@example.com",
          password: "password123",
          password_confirmation: "password123",
          name: "New User #{i}",
          role: "kid",
          family_id: families(:smith_family).id
        }
      }
      # Should not be rate limited (may fail validation but not 429)
      assert_not_equal 429, response.status
    end
  end

  test "throttles registration after 5 attempts from same IP" do
    6.times do |i|
      post "/users", params: {
        user: {
          email: "user#{i}@example.com",
          password: "password123",
          password_confirmation: "password123",
          name: "User #{i}",
          role: "kid",
          family_id: families(:smith_family).id
        }
      }
    end
    assert_equal 429, response.status
    assert_includes response.body, "Too many requests"
  end

  # Login throttling tests
  test "allows login attempts within limit" do
    # Use different emails to avoid email throttle (limit 5)
    10.times do |i|
      post "/users/sign_in", params: {
        user: { email: "test#{i}@example.com", password: "wrongpassword" }
      }
      assert_not_equal 429, response.status
    end
  end

  test "throttles login after 10 attempts from same IP" do
    # Use different emails to only test IP throttle (limit 10)
    11.times do |i|
      post "/users/sign_in", params: {
        user: { email: "user#{i}@example.com", password: "wrongpassword" }
      }
    end
    assert_equal 429, response.status
  end

  test "throttles login after 5 attempts with same email" do
    6.times do
      post "/users/sign_in", params: {
        user: { email: "target@example.com", password: "wrongpassword" }
      }
    end
    assert_equal 429, response.status
  end

  # Password reset throttling tests
  test "allows password reset requests within limit" do
    5.times do |i|
      post "/users/password", params: {
        user: { email: "user#{i}@example.com" }
      }
      assert_not_equal 429, response.status
    end
  end

  test "throttles password reset after 5 attempts from same IP" do
    6.times do |i|
      post "/users/password", params: {
        user: { email: "user#{i}@example.com" }
      }
    end
    assert_equal 429, response.status
  end

  test "throttles password reset after 3 attempts with same email" do
    4.times do
      post "/users/password", params: {
        user: { email: "target@example.com" }
      }
    end
    assert_equal 429, response.status
  end

  # Response format test
  test "throttled response has correct content type" do
    11.times do
      post "/users/sign_in", params: {
        user: { email: "test@example.com", password: "wrong" }
      }
    end
    assert_equal "text/html", response.media_type
  end
end
