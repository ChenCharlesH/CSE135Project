class NewPurchase < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :user, allow_blank: false, numericality: { only_integer: true }
  validates :product, allow_blank: false, numericality: { only_integer: true }
  validates :quantity, allow_blank: false, numericality: { only_integer: true }
end
