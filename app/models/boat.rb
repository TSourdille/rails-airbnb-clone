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
  has_attachments :photos, maximum: 3

  validates :boat_type, :name, :city, :capacity, :day_rate, :user_id, presence: true

  geocoded_by :city
  after_validation :geocode, if: :city_changed?
end
