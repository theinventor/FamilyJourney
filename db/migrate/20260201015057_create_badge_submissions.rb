class CreateBadgeSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :badge_submissions do |t|
      t.references :badge, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "pending_review", null: false
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.text :kid_notes
      t.text :parent_feedback

      t.timestamps
    end

    add_index :badge_submissions, [ :badge_id, :user_id, :status ]
  end
end
