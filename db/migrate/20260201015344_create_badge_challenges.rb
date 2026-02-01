class CreateBadgeChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :badge_challenges do |t|
      t.references :badge, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
