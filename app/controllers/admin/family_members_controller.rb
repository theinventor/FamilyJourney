class Admin::FamilyMembersController < Admin::BaseController
  def index
    @parents = current_family.parents.order(created_at: :asc)
    @pending_invites_count = current_family.invites.active.count
  end
end
