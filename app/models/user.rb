class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable
         # :recoverable, :rememberable, :trackable

  validates :age, :numericality => { less_than_or_equal_to: 150, greater_than_or_equal_to: 0, :only_integer => true}

  has_many :categories
  has_many :carts

  has_many :products, through: :carts

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
