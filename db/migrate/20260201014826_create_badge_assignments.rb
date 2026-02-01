class CreateBadgeAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :badge_assignments do |t|
      t.references :badge, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :assigned_by, foreign_key: { to_table: :users }
      t.boolean :active, default: true, null: false
      t.datetime :assigned_at

      t.timestamps
    end

    add_index :badge_assignments, [:badge_id, :group_id], unique: true
  end
end
