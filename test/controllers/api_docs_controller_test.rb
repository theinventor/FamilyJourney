require "test_helper"

class ApiDocsControllerTest < ActionDispatch::IntegrationTest
  test "api docs show official cli and assistant guidance to parents" do
    parent = users(:parent_alice)
    sign_in_as(parent)

    get api_docs_path

    assert_response :success
    assert_select "a[href='https://github.com/theinventor/familyjourney-cli']", text: /CLI repo/
    assert_select "a[href='#{agents_txt_path}']", text: "/agents.txt"
    assert_includes response.body, "go install github.com/theinventor/familyjourney-cli/cmd/familyjourney@latest"
    assert_includes response.body, "familyjourney auth save --profile default"
    assert_includes response.body, "familyjourney family get"
    assert_includes response.body, "familyjourney submissions approve SUBMISSION_ID --feedback \"Nice work.\""
    assert_includes response.body, "familyjourney skill get familyjourney"
    assert_includes response.body, "Approvals, denials, deletes, password resets, publish actions, and prize changes need a current parent command."
  end

  private

  def sign_in_as(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
  end
end
