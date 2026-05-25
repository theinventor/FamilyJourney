require "test_helper"

class Api::V1::BadgeSubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent_alice)
    @parent.update!(api_token: "test-parent-token")
    @headers = {
      "Authorization" => "Bearer test-parent-token",
      "Content-Type" => "application/json"
    }
  end

  test "show returns detailed submission JSON using current model fields" do
    submission = badge_submissions(:pending_submission)

    get api_v1_badge_submission_path(submission), headers: @headers

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal submission.id, body["id"]
    assert_equal submission.kid_notes, body["kid_notes"]
    assert_equal submission.kid_notes, body["notes"]
    assert body["badge"].present?
  end

  test "deny stores feedback from reason" do
    submission = badge_submissions(:pending_submission)

    post deny_api_v1_badge_submission_path(submission),
      params: { reason: "Please add a clearer photo" }.to_json,
      headers: @headers

    assert_response :success
    submission.reload
    assert submission.denied?
    assert_equal @parent, submission.reviewed_by
    assert_equal "Please add a clearer photo", submission.parent_feedback

    body = JSON.parse(response.body)
    assert_equal "Please add a clearer photo", body["parent_feedback"]
    assert_equal "Please add a clearer photo", body["denial_reason"]
  end
end
