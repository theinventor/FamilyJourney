require "test_helper"

class Api::V1::BadgesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent_alice)
    @parent.update!(api_token: "test-parent-token")
    @headers = {
      "Authorization" => "Bearer test-parent-token",
      "Content-Type" => "application/json"
    }
  end

  test "create accepts nested challenge titles" do
    post api_v1_badges_path,
      params: {
        badge: {
          title: "Practice piano",
          description: "Practice for 20 minutes",
          points: 10,
          badge_challenges_attributes: [
            {
              title: "Practice scales",
              description: "Play scales for five minutes",
              position: 1
            }
          ]
        }
      }.to_json,
      headers: @headers

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Practice piano", body["title"]
    assert_equal 1, body["challenges"].length
    assert_equal "Practice scales", body["challenges"].first["title"]
  end
end
