class CreateBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges do |t|
      t.string :title, null: false
      t.text :description
      t.text :instructions
      t.integer :points, default: 0, null: false
      t.string :status, default: "draft", null: false
      t.datetime :published_at
      t.references :badge_category, foreign_key: true
      t.references :family, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :badges, [:family_id, :status]
  end
end
