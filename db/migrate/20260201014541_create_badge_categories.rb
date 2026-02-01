class CreateBadgeCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :badge_categories do |t|
      t.string :name
      t.integer :position
      t.references :family, null: false, foreign_key: true

      t.timestamps
    end
  end
end
