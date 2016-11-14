class Boat < ApplicationRecord
  belongs_to :user
  has_many :bookings
  has_many :availabilities
  # has_one :user, through: :booking

  validates :boat_type, :name, :city, :capacity, :day_rate, :user_id, presence: true
end
