class Purchase < ApplicationRecord
  has_many :user
  has_many :product
end
