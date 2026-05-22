require "test_helper"

class Api::V1::ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent_alice)
    @parent.update!(api_token: "test-parent-token")
    @headers = {
      "Authorization" => "Bearer test-parent-token",
      "Content-Type" => "application/json"
    }
  end

  test "create accepts title and returns challenge JSON" do
    badge = badges(:simple_badge)

    post api_v1_challenges_path,
      params: {
        badge_id: badge.id,
        challenge: {
          title: "Practice scales",
          description: "Log 20 minutes",
          position: 2
        }
      }.to_json,
      headers: @headers

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Practice scales", body["title"]
    assert_equal "Log 20 minutes", body["description"]
    assert_equal badge.id, body["badge_id"]
  end

  test "update accepts title" do
    challenge = badge_challenges(:challenge_one)

    patch api_v1_challenge_path(challenge),
      params: {
        challenge: {
          title: "Read two chapters",
          description: "Read two chapters and write notes"
        }
      }.to_json,
      headers: @headers

    assert_response :success
    challenge.reload
    assert_equal "Read two chapters", challenge.title
    assert_equal "Read two chapters", JSON.parse(response.body)["title"]
  end
end
