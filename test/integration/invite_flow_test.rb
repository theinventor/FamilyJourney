require "test_helper"

class InviteFlowTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:smith_family)
    @parent = users(:parent_alice)
    @active_invite = invites(:active_invite)
  end

  def sign_in_as(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }
  end

  test "parent can create invite" do
    sign_in_as @parent

    get new_admin_invite_path
    assert_response :success

    assert_difference "Invite.count", 1 do
      post admin_invites_path, params: {
        invite: {
          email: "newparent@example.com"
        }
      }
    end

    assert_redirected_to admin_invites_path

    invite = Invite.last
    assert_equal @family.id, invite.family_id
    assert_equal @parent.id, invite.invited_by_id
    assert_equal "pending", invite.status
    assert_not_nil invite.token
  end

  test "parent can view invites list" do
    sign_in_as @parent

    get admin_invites_path
    assert_response :success
    assert_match @active_invite.token, response.body
  end

  test "parent can cancel invite" do
    sign_in_as @parent

    assert_difference "Invite.pending.count", -1 do
      delete admin_invite_path(@active_invite)
    end

    assert_redirected_to admin_invites_path
    @active_invite.reload
    assert_equal "cancelled", @active_invite.status
  end

  test "new user can sign up via invite link" do
    get invite_path(@active_invite.token)
    assert_redirected_to new_user_registration_path(invite_token: @active_invite.token)

    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        invite_token: @active_invite.token,
        user: {
          name: "New Parent",
          email: "newparent3@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    new_user = User.last
    assert_equal @family.id, new_user.family_id
    assert_equal "parent", new_user.role

    @active_invite.reload
    assert_equal "accepted", @active_invite.status
    assert_equal new_user.id, @active_invite.accepted_by_id
  end

  test "expired invite shows error page" do
    expired_invite = invites(:expired_invite)

    get invite_path(expired_invite.token)
    assert_response :success
    assert_match /expired/i, response.body
  end

  test "invalid invite token redirects to root" do
    get invite_path("invalid_token_12345")
    assert_redirected_to root_path
  end

  test "parent can view family members" do
    sign_in_as @parent

    get admin_family_members_path
    assert_response :success
    assert_match @parent.name, response.body
  end
end
