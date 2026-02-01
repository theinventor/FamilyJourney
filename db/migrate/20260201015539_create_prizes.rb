class CreatePrizes < ActiveRecord::Migration[8.1]
  def change
    create_table :prizes do |t|
      t.string :name, null: false
      t.text :description
      t.integer :point_cost, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.references :family, null: false, foreign_key: true

      t.timestamps
    end
  end
end
