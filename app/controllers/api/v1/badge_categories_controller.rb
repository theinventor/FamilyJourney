module Api
  module V1
    class BadgeCategoriesController < BaseController
      def index
        categories = current_user.family.badge_categories
        render json: categories.map { |c| category_json(c) }
      end

      def show
        category = current_user.family.badge_categories.find(params[:id])
        render json: category_json(category, detailed: true)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Category not found")
      end

      def create
        category = current_user.family.badge_categories.build(category_params)

        if category.save
          render json: category_json(category), status: :created
        else
          render_unprocessable(category.errors.full_messages)
        end
      end

      def update
        category = current_user.family.badge_categories.find(params[:id])

        if category.update(category_params)
          render json: category_json(category)
        else
          render_unprocessable(category.errors.full_messages)
        end
      rescue ActiveRecord::RecordNotFound
        render_not_found("Category not found")
      end

      def destroy
        category = current_user.family.badge_categories.find(params[:id])
        category.destroy
        render json: { message: "Category deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Category not found")
      end

      def move_up
        category = current_user.family.badge_categories.unscoped.find(params[:id])
        category.move_up
        render json: category_json(category)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Category not found")
      end

      def move_down
        category = current_user.family.badge_categories.unscoped.find(params[:id])
        category.move_down
        render json: category_json(category)
      rescue ActiveRecord::RecordNotFound
        render_not_found("Category not found")
      end

      private

      def category_params
        params.require(:badge_category).permit(:name, :description)
      end

      def category_json(category, detailed: false)
        json = {
          id: category.id,
          name: category.name,
          description: category.description,
          position: category.position,
          created_at: category.created_at,
          updated_at: category.updated_at
        }

        if detailed
          json[:badges] = category.badges.map do |b|
            { id: b.id, title: b.title, points: b.points, status: b.status }
          end
        end

        json
      end
    end
  end
end
