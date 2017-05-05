class Category < ApplicationRecord
  belongs_to :user
  has_many :products

  validates :unique_name, presence: true, allow_blank: false
  validates :desc, presence: true, allow_blank: false
end
