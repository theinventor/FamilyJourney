require "test_helper"

class BadgeTest < ActiveSupport::TestCase
  setup do
    @simple_badge = badges(:simple_badge)
    @multi_badge = badges(:multi_challenge_badge)
    @draft_badge = badges(:draft_badge)
    @unassigned_badge = badges(:unassigned_badge)
    @kid_bob = users(:kid_bob)
    @kid_charlie = users(:kid_charlie)
    @parent = users(:parent_alice)
  end

  # Validation tests
  test "requires title" do
    badge = Badge.new(family: families(:smith_family), created_by: @parent, points: 10)
    assert_not badge.valid?
    assert_includes badge.errors[:title], "can't be blank"
  end

  test "requires non-negative points" do
    badge = Badge.new(
      title: "Test",
      family: families(:smith_family),
      created_by: @parent,
      points: -5
    )
    assert_not badge.valid?
    assert_includes badge.errors[:points], "must be greater than or equal to 0"
  end

  # Status tests
  test "publish! sets status and published_at" do
    assert @draft_badge.draft?
    assert_nil @draft_badge.published_at

    @draft_badge.publish!

    assert @draft_badge.published?
    assert_not_nil @draft_badge.published_at
  end

  test "unpublish! sets status to draft and clears published_at" do
    assert @simple_badge.published?

    @simple_badge.unpublish!

    assert @simple_badge.draft?
    assert_nil @simple_badge.published_at
  end

  # Multi-challenge tests
  test "multi_challenge? returns true when badge has challenges" do
    assert @multi_badge.multi_challenge?
  end

  test "multi_challenge? returns false when badge has no challenges" do
    assert_not @simple_badge.multi_challenge?
  end

  # Assignment tests
  test "assigned_to_user? returns true when user is in assigned group" do
    assert @simple_badge.assigned_to_user?(@kid_bob)
  end

  test "assigned_to_user? returns false for unassigned badge" do
    assert_not @unassigned_badge.assigned_to_user?(@kid_bob)
  end

  # Earned tests
  test "earned_by? returns true when user has approved submission" do
    assert @simple_badge.earned_by?(@kid_charlie)
  end

  test "earned_by? returns false when user has no approved submission" do
    assert_not @simple_badge.earned_by?(@kid_bob)
  end

  # Availability tests
  test "available_for? returns true for published, assigned, unearned badge" do
    assert @simple_badge.available_for?(@kid_bob)
  end

  test "available_for? returns false for draft badge" do
    assert_not @draft_badge.available_for?(@kid_bob)
  end

  test "available_for? returns false for unassigned badge" do
    assert_not @unassigned_badge.available_for?(@kid_bob)
  end

  test "available_for? returns false when already earned" do
    assert_not @simple_badge.available_for?(@kid_charlie)
  end

  # Challenge progress tests
  test "challenges_completed_for returns count of completed challenges" do
    # Bob has completed 2 of 3 challenges
    assert_equal 2, @multi_badge.challenges_completed_for(@kid_bob)
  end

  test "challenges_completed_for returns 0 for non-multi-challenge badge" do
    assert_equal 0, @simple_badge.challenges_completed_for(@kid_bob)
  end

  test "all_challenges_completed_for? returns false when some challenges remain" do
    assert_not @multi_badge.all_challenges_completed_for?(@kid_bob)
  end

  test "all_challenges_completed_for? returns true when all completed" do
    # Complete the third challenge
    ChallengeCompletion.create!(
      badge_challenge: badge_challenges(:challenge_three),
      user: @kid_bob
    )
    assert @multi_badge.all_challenges_completed_for?(@kid_bob)
  end

  test "all_challenges_completed_for? returns true for non-multi-challenge badge" do
    assert @simple_badge.all_challenges_completed_for?(@kid_bob)
  end

  # In progress tests
  test "in_progress_for? returns true when some challenges completed" do
    assert @multi_badge.in_progress_for?(@kid_bob)
  end

  test "in_progress_for? returns false for non-multi-challenge badge" do
    assert_not @simple_badge.in_progress_for?(@kid_bob)
  end

  test "in_progress_for? returns false when no challenges completed" do
    assert_not @multi_badge.in_progress_for?(@kid_charlie)
  end

  test "in_progress_for? returns false when all challenges completed" do
    ChallengeCompletion.create!(
      badge_challenge: badge_challenges(:challenge_three),
      user: @kid_bob
    )
    assert_not @multi_badge.in_progress_for?(@kid_bob)
  end

  # Pending tests
  test "pending_for? returns true when user has pending submission" do
    assert @multi_badge.pending_for?(@kid_bob)
  end

  test "pending_for? returns false when no pending submission" do
    assert_not @multi_badge.pending_for?(@kid_charlie)
  end

  # Denied tests
  test "denied_for? returns true when latest submission was denied" do
    assert @simple_badge.denied_for?(@kid_bob)
  end

  test "denied_for? returns false when no denied submission" do
    assert_not @simple_badge.denied_for?(@kid_charlie)
  end

  # State machine tests
  test "state_for returns :earned when badge is earned" do
    assert_equal :earned, @simple_badge.state_for(@kid_charlie)
  end

  test "state_for returns :pending when submission is pending review" do
    assert_equal :pending, @multi_badge.state_for(@kid_bob)
  end

  test "state_for returns :denied when latest submission was denied" do
    # Create a new submission for bob that gets denied, with no pending submissions
    badge_submissions(:pending_submission).destroy!
    assert_equal :denied, @simple_badge.state_for(@kid_bob)
  end

  test "state_for returns :ready when all challenges completed" do
    # Complete all challenges for Charlie
    badge_challenges(:challenge_one, :challenge_two, :challenge_three).each do |challenge|
      ChallengeCompletion.create!(badge_challenge: challenge, user: @kid_charlie)
    end
    assert_equal :ready, @multi_badge.state_for(@kid_charlie)
  end

  test "state_for returns :in_progress when some challenges completed" do
    # Delete Bob's pending submission so state reflects progress
    badge_submissions(:pending_submission).destroy!
    badge_submissions(:denied_submission).destroy!
    assert_equal :in_progress, @multi_badge.state_for(@kid_bob)
  end

  test "state_for returns :available when badge is available but not started" do
    assert_equal :available, @multi_badge.state_for(@kid_charlie)
  end
end
