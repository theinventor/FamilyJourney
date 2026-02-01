class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.references :family, null: false, foreign_key: true

      t.timestamps
    end
  end
end
