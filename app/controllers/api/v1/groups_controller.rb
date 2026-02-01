module Api
  module V1
    class GroupsController < BaseController
      def index
        groups = current_user.family.groups.includes(:users)
        render json: groups.map { |g| group_json(g) }
      end

      def show
        group = current_user.family.groups.find(params[:id])
        render json: group_json(group, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Group not found")
      end

      def create
        group = current_user.family.groups.build(group_params)

        if group.save
          render json: group_json(group, detailed: true), status: :created
        else
          render_unprocessable(group.errors.full_messages)
        end
      end

      def update
        group = current_user.family.groups.find(params[:id])

        if group.update(group_params)
          render json: group_json(group, detailed: true)
        else
          render_unprocessable(group.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Group not found")
      end

      def destroy
        group = current_user.family.groups.find(params[:id])
        group.destroy
        render json: { message: "Group deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Group not found")
      end

      def add_member
        group = current_user.family.groups.find(params[:id])
        kid = current_user.family.kids.find(params[:user_id])

        group.users << kid unless group.users.include?(kid)
        render json: group_json(group, detailed: true)
      rescue ActiveRecord::RecordNotFound => e
        render_not_found(e.message)
      end

      def remove_member
        group = current_user.family.groups.find(params[:id])
        kid = current_user.family.kids.find(params[:user_id])

        group.users.delete(kid)
        render json: group_json(group, detailed: true)
      rescue ActiveRecord::RecordNotFound => e
        render_not_found(e.message)
      end

      private

      def group_params
        params.require(:group).permit(:name, :description)
      end

      def group_json(group, detailed: false)
        json = {
          id: group.id,
          name: group.name,
          description: group.description,
          created_at: group.created_at,
          updated_at: group.updated_at
        }

        if detailed
          json[:members] = group.users.map do |u|
            { id: u.id, name: u.name, email: u.email, role: u.role }
          end
          json[:badges_count] = group.badges.count
        end

        json
      end
    end
  end
end
