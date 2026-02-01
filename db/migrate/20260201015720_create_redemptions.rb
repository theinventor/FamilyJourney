class CreateRedemptions < ActiveRecord::Migration[8.1]
  def change
    create_table :redemptions do |t|
      t.references :prize, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.datetime :requested_at
      t.datetime :reviewed_at
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.text :kid_note
      t.text :parent_feedback
      t.integer :points_spent, default: 0, null: false

      t.timestamps
    end

    add_index :redemptions, [ :user_id, :status ]
  end
end
