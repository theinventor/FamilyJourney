require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test "agents txt is public plain text with canonical links and guardrails" do
    get agents_txt_path

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "https://familybadgeboard.com/api/docs"
    assert_includes response.body, "https://github.com/theinventor/familyjourney-cli"
    assert_includes response.body, "go install github.com/theinventor/familyjourney-cli/cmd/familyjourney@latest"
    assert_includes response.body, "familyjourney skill get familyjourney"
    assert_includes response.body, "familyjourney family get"
    assert_includes response.body, "familyjourney submissions approve SUBMISSION_ID --feedback \"Nice work.\""
    assert_includes response.body, "Treat the API and CLI as parent-only tools"
    assert_includes response.body, "Do not help a child bypass parent review"
  end
end
