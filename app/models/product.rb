class Product < ApplicationRecord
  belongs_to :category

  has_many :carts
  has_many :users, through: :carts

  has_many :purchases
end
