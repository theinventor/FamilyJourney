class Admin::FamilyMembersController < Admin::BaseController
  def index
    @parents = current_family.parents.order(created_at: :asc)
  end
end
