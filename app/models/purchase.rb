class Purchase < ApplicationRecord
  trigger.after(:insert) do
    "INSERT INTO new_purchases(user,product,quantity,time,created_at,updated_at)
     VALUES(NEW.user,NEW.product,NEW.quantity,NEW.time,NEW.created_at,NEW.updated_at)"
  end
end
