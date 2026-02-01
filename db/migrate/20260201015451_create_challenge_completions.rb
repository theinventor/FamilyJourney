class CreateChallengeCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :challenge_completions do |t|
      t.references :badge_challenge, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :completed_at
      t.text :kid_notes

      t.timestamps
    end
  end
end
