require "test_helper"

class InviteTest < ActiveSupport::TestCase
  setup do
    @family = families(:smith_family)
    @parent = users(:parent_alice)
    @active_invite = invites(:active_invite)
    @expired_invite = invites(:expired_invite)
  end

  test "should generate token on create" do
    invite = @family.invites.new(invited_by: @parent, expires_at: 7.days.from_now)
    assert invite.save
    assert_not_nil invite.token
    assert invite.token.length > 20
  end

  test "should set expiration on create" do
    invite = @family.invites.new(invited_by: @parent)
    assert invite.save
    assert_not_nil invite.expires_at
    assert invite.expires_at > Time.current
  end

  test "should validate invited_by is a parent" do
    kid = users(:kid_bob)
    invite = @family.invites.new(invited_by: kid, expires_at: 7.days.from_now)
    assert_not invite.save
    assert_includes invite.errors[:invited_by], "must be a parent"
  end

  test "should identify expired invites" do
    assert @expired_invite.expired?
    assert_not @active_invite.expired?
  end

  test "should identify if invite can be accepted" do
    assert @active_invite.can_be_accepted?
    assert_not @expired_invite.can_be_accepted?
  end

  test "should reject accepting expired invite" do
    assert_not @expired_invite.can_be_accepted?
    assert @expired_invite.expired?
  end

  test "should reject accepting invite for user in different family" do
    # Create a user in a different family
    other_family = Family.create!(name: "Other Family")
    other_parent = User.create!(
      name: "Other Parent",
      email: "other@example.com",
      password: "password123",
      family: other_family,
      role: "parent"
    )

    assert_raises(RuntimeError, "User is already in a different family") do
      @active_invite.accept!(other_parent)
    end
  end

  test "should allow accepting invite for user already in same family" do
    # User in the same family should not raise an error
    # This handles the case where registration already set the family
    assert_equal @family.id, @parent.family_id

    # Should not raise error since user is in the same family
    @active_invite.accept!(@parent)

    @active_invite.reload
    assert_equal "accepted", @active_invite.status
    assert_equal @parent.id, @active_invite.accepted_by_id
  end

  test "should cancel pending invite" do
    assert @active_invite.pending?
    @active_invite.cancel!
    assert_equal "cancelled", @active_invite.status
  end

  test "should find active invites" do
    active = Invite.active
    assert_includes active, @active_invite
    assert_not_includes active, @expired_invite
  end
end
