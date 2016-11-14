class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :boats
  has_many :bookings
  has_many :booked_boats, through: :boats, source: :bookings
  validates :first_name, :last_name, presence: true
end
