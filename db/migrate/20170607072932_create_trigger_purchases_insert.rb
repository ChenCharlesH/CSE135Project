# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerPurchasesInsert < ActiveRecord::Migration
  def up
    create_trigger("purchases_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("purchases").
        after(:insert) do
      <<-SQL_ACTIONS
      INSERT INTO new_purchases(user_id, product_id, quantity, time, created_at, updated_at)
      VALUES(NEW.user,NEW.product,NEW.quantity,NEW.time,NEW.created_at,NEW.updated_at);
      SQL_ACTIONS
    end
  end

  def down
    drop_trigger("purchases_after_insert_row_tr", "purchases", :generated => true)
  end
end
