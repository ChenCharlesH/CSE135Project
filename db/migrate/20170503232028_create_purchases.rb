class CreatePurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :purchases do |t|
      t.integer :user, null: false
      t.integer :product, null: false
      t.integer :quantity, null: false
      t.datetime :time, null: false, default: DateTime.current()

      t.timestamps
    end
  end
end
