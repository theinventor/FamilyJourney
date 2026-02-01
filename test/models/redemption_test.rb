require "test_helper"

class RedemptionTest < ActiveSupport::TestCase
  setup do
    @kid_charlie = users(:kid_charlie)
    @kid_bob = users(:kid_bob)
    @parent = users(:parent_alice)
    @ice_cream = prizes(:ice_cream)
    @movie_night = prizes(:movie_night)
    @expensive_prize = prizes(:expensive_prize)
  end

  # Points calculation tests
  test "charlie has correct lifetime points from approved badge" do
    # Charlie has one approved submission for simple_badge worth 10 points
    assert_equal 10, @kid_charlie.lifetime_points
  end

  test "charlie has correct spent points from approved redemption" do
    # Charlie has one approved redemption for ice cream worth 20 points
    assert_equal 20, @kid_charlie.spent_points
  end

  test "charlie has negative available points (spent more than earned)" do
    # Charlie earned 10, spent 20 = -10 available
    assert_equal(-10, @kid_charlie.available_points)
  end

  test "bob has zero points (no approved submissions)" do
    assert_equal 0, @kid_bob.lifetime_points
    assert_equal 0, @kid_bob.available_points
  end

  # Affordability tests
  test "can_afford? returns false when not enough points" do
    assert_not @kid_charlie.can_afford?(@ice_cream)
  end

  test "can_afford? returns true when enough points" do
    # Give charlie enough points via an approved submission
    badge = badges(:multi_challenge_badge)
    BadgeSubmission.create!(
      badge: badge,
      user: @kid_charlie,
      status: :approved,
      reviewed_by: @parent,
      reviewed_at: Time.current
    )
    # Charlie now has 10 + 50 = 60 points, spent 20 = 40 available
    assert @kid_charlie.can_afford?(@ice_cream)
  end

  # Redemption validation tests
  test "redemption requires user can afford prize" do
    redemption = Redemption.new(
      prize: @expensive_prize,
      user: @kid_bob
    )
    assert_not redemption.valid?
    assert_includes redemption.errors[:base], "You don't have enough points for this prize"
  end

  test "redemption sets points_spent on create" do
    give_charlie_points(50)
    redemption = Redemption.create!(
      prize: @movie_night,
      user: @kid_charlie
    )
    assert_equal 15, redemption.points_spent
  end

  test "redemption sets requested_at on create" do
    give_charlie_points(50)
    redemption = Redemption.create!(
      prize: @movie_night,
      user: @kid_charlie
    )
    assert_not_nil redemption.requested_at
  end

  # Approve tests
  test "approve! updates status and reviewer" do
    # Give Charlie enough points first (needs 15 for movie_night, has -10)
    give_charlie_points(30)

    redemption = redemptions(:pending_redemption)
    result = redemption.approve!(@parent, feedback: "Enjoy!")

    assert result
    assert redemption.approved?
    assert_equal @parent, redemption.reviewed_by
    assert_not_nil redemption.reviewed_at
    assert_equal "Enjoy!", redemption.parent_feedback
  end

  test "approve! returns false when user cannot afford anymore" do
    # Create a situation where charlie's points dropped
    redemption = redemptions(:pending_redemption)

    # Reduce charlie's available points by denying their approved badge submission
    badge_submissions(:approved_submission).update!(status: :denied)

    result = redemption.approve!(@parent)
    assert_not result
    assert redemption.pending?
  end

  # Deny tests
  test "deny! updates status and sets points_spent to 0" do
    redemption = redemptions(:pending_redemption)
    redemption.deny!(@parent, feedback: "Not this week")

    assert redemption.denied?
    assert_equal @parent, redemption.reviewed_by
    assert_not_nil redemption.reviewed_at
    assert_equal "Not this week", redemption.parent_feedback
    assert_equal 0, redemption.points_spent
  end

  # Status enum tests
  test "redemption has correct status values" do
    assert Redemption.statuses.key?("pending")
    assert Redemption.statuses.key?("approved")
    assert Redemption.statuses.key?("denied")
  end

  private

  def give_charlie_points(amount)
    badge = Badge.create!(
      title: "Bonus Badge",
      points: amount,
      family: families(:smith_family),
      created_by: @parent,
      status: :published,
      published_at: Time.current
    )
    BadgeSubmission.create!(
      badge: badge,
      user: @kid_charlie,
      status: :approved,
      reviewed_by: @parent,
      reviewed_at: Time.current
    )
  end
end
