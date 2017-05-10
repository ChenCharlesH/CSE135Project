class Product < ApplicationRecord
  belongs_to :category

  has_many :carts
  has_many :users, through: :carts

  validates :unique_name, presence: true, allow_blank: false
  validates :sku, presence: true, allow_blank: false
  validates :price, :numericality => { :only_integer => true}

end
