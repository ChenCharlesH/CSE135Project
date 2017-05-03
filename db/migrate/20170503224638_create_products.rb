class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :unique_name, null: false
      t.string :sku, null: false
      t.references :category, foreign_key: true, null: false
      t.integer :price, null: false, default: 0

      t.timestamps
    end
    add_index :products, :unique_name, unique: true
  end
end
