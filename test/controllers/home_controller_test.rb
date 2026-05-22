require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "guest root renders assistant native section with CLI quick start" do
    get root_path

    assert_response :success
    assert_select "section#ai-assistants" do
      assert_select "a[href='#{api_docs_path}']", text: /API docs/
      assert_select "a[href='#{agents_txt_path}']", text: "/agents.txt"
      assert_select "a[href='https://github.com/theinventor/familyjourney-cli']", text: /CLI repo/
      assert_select "code", text: /go install github\.com\/theinventor\/familyjourney-cli\/cmd\/familyjourney@latest/
      assert_select "code", text: /familyjourney family get/
      assert_select "code", text: /familyjourney submissions approve SUBMISSION_ID --feedback "Nice work\."/
      assert_select "code", text: /familyjourney skill get familyjourney/
    end
  end

  test "authenticated root still renders parent dashboard" do
    parent = users(:parent_alice)

    post user_session_path, params: {
      user: {
        email: parent.email,
        password: "password123"
      }
    }

    assert_redirected_to root_path

    get root_path

    assert_response :success
    assert_select "#parent-dashboard"
    assert_select "h1", text: "Welcome back!"
  end
end
