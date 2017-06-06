class CreateNewPurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :new_purchases do |t|
      t.integer :user, null: false
      t.integer :product, null: false
      t.integer :quantity, null: false
      t.datetime :time, null: false, default: '2017-05-10 20:47:13'

      t.timestamps
    end
  end
end
