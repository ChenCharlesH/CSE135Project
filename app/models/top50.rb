class Top50 < ApplicationRecord
  belongs_to :category

  validates :state, allow_blank: false
  validates :product_name, allow_blank: false
  validates :category, allow_blank: false
  validates :total, allow_blank: false, numericality: { only_integer: true }
end
