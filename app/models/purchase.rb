class Purchase < ApplicationRecord
  trigger.after(:insert) do
    "INSERT INTO new_purchases(user,product,quantity,time)
     VALUES(NEW.user,NEW.product,NEW.quantity,NEW.time)"
  end
end
