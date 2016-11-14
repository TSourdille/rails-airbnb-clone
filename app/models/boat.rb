class Boat < ApplicationRecord
  belongs_to :user
  has_many :bookings, :availabilities
  has_one :user, through: :bookings

  validates :type, :name, :city, :capacity, :day_rate, :user_id, presence: true
end
