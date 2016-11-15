class Boat < ApplicationRecord
  BOAT_TYPES = [
    "Bateau à moteur",
    "Semi-rigide",
    "Zodiac",
    "Voilier",
    "Multicoque",
    "Péniche"
  ]
  CITIES = []

  belongs_to :user
  has_many :bookings
  has_many :availabilities
  # has_one :user, through: :booking

  validates :boat_type, :name, :city, :capacity, :day_rate, :user_id, presence: true
  validates :boat_type, inclusion: { in: BOAT_TYPES }
end
