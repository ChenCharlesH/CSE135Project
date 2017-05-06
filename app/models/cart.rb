class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :user_id, allow_blank: false, numericality: { only_integer: true }
  validates :product_id, allow_blank: false, numericality: { only_integer: true }
  validates :quantity, allow_blank: false, numericality: { greater_than_or_equal_to: 1, only_integer: true }

end
