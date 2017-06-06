class CreateTop50s < ActiveRecord::Migration[5.0]
  def change
    create_table :top50s do |t|
      t.string :state, null: false
      t.string :product_name, null: false
      t.references :category, foreign_key: true, null: false
      t.integer :total, null: false

      t.timestamps
    end
  end
end
