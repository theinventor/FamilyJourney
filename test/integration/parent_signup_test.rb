require "test_helper"

class ParentSignupTest < ActionDispatch::IntegrationTest
  test "parent can sign up with name and family name" do
    # Visit signup page
    get new_user_registration_path
    assert_response :success

    # Fill out and submit the form
    assert_difference ["User.count", "Family.count"], 1 do
      post user_registration_path, params: {
        user: {
          name: "John Smith",
          email: "john@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        family_name: "Smith Family"
      }
    end

    # Verify redirect
    assert_redirected_to root_path

    # Verify user was created correctly
    user = User.last
    assert_equal "John Smith", user.name
    assert_equal "john@example.com", user.email
    assert_equal "parent", user.role

    # Verify family was created and linked
    assert_not_nil user.family
    assert_equal "Smith Family", user.family.name
  end

  test "signup fails without family name" do
    get new_user_registration_path
    assert_response :success

    assert_no_difference ["User.count", "Family.count"] do
      post user_registration_path, params: {
        user: {
          name: "Jane Doe",
          email: "jane@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        family_name: ""
      }
    end

    assert_response :unprocessable_entity
  end

  test "signup fails without name" do
    get new_user_registration_path
    assert_response :success

    assert_no_difference ["User.count", "Family.count"] do
      post user_registration_path, params: {
        user: {
          name: "",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        family_name: "Test Family"
      }
    end

    assert_response :unprocessable_entity
  end

  test "honeypot prevents bot signups" do
    assert_no_difference ["User.count", "Family.count"] do
      post user_registration_path, params: {
        user: {
          name: "Bot User",
          email: "bot@example.com",
          password: "password123",
          password_confirmation: "password123"
        },
        family_name: "Bot Family",
        website: "http://spam.com"
      }
    end

    assert_redirected_to root_path
    assert_nil User.find_by(email: "bot@example.com")
  end

  test "family is cleaned up if user creation fails" do
    get new_user_registration_path
    assert_response :success

    # Try to create user with duplicate email
    existing_user = User.create!(
      name: "Existing User",
      email: "existing@example.com",
      password: "password123",
      family: Family.create!(name: "Existing Family"),
      role: "parent"
    )

    initial_family_count = Family.count

    post user_registration_path, params: {
      user: {
        name: "New User",
        email: "existing@example.com", # Duplicate email
        password: "password123",
        password_confirmation: "password123"
      },
      family_name: "New Family"
    }

    # Family should not increase because the transaction should roll back
    # or the family should be destroyed
    assert_equal initial_family_count, Family.count
  end
end
