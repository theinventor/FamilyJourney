class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :invites do |t|
      t.string :token, null: false
      t.string :email
      t.references :family, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.references :accepted_by, null: true, foreign_key: { to_table: :users }
      t.datetime :accepted_at
      t.datetime :expires_at, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
    add_index :invites, :token, unique: true
  end
end
