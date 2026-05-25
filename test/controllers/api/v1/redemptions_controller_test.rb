require "test_helper"

class Api::V1::RedemptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent_alice)
    @parent.update!(api_token: "test-parent-token")
    @headers = {
      "Authorization" => "Bearer test-parent-token",
      "Content-Type" => "application/json"
    }
  end

  test "show returns detailed redemption JSON with requested_at and feedback" do
    redemption = redemptions(:approved_redemption)

    get api_v1_redemption_path(redemption), headers: @headers

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal redemption.id, body["id"]
    assert_equal redemption.requested_at.as_json, body["requested_at"]
    assert_equal redemption.parent_feedback, body["parent_feedback"]
    assert body["prize"].present?
  end

  test "deny stores feedback and zeroes spent points" do
    redemption = redemptions(:pending_redemption)

    post deny_api_v1_redemption_path(redemption),
      params: { feedback: "Not this week" }.to_json,
      headers: @headers

    assert_response :success
    redemption.reload
    assert redemption.denied?
    assert_equal @parent, redemption.reviewed_by
    assert_equal "Not this week", redemption.parent_feedback
    assert_equal 0, redemption.points_spent

    body = JSON.parse(response.body)
    assert_equal "Not this week", body["parent_feedback"]
  end
end
