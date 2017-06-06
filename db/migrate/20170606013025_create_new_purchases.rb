class CreateNewPurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :new_purchases do |t|
      t.references :user, foreign_key: true, null: false
      t.references :product, foreign_key: true, null: false
      t.integer :quantity, null: false
      t.datetime :time, null: false, default: '2017-05-10 20:47:13'

      t.timestamps
    end
  end
end
