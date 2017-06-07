class Purchase < ApplicationRecord
  trigger.after(:insert) do
    <<-SQL
      INSERT INTO new_purchases(user_id, product_id, quantity, time, created_at, updated_at)
      VALUES(NEW.user,NEW.product,NEW.quantity,NEW.time,NEW.created_at,NEW.updated_at)
    SQL
  end
end
