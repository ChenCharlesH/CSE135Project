class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :unique_name, null: false
      t.string :desc, limit: 1023

      t.timestamps
    end
    add_index :categories, :unique_name, unique: true
  end
end
