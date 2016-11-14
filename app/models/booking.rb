class Booking < ApplicationRecord
  belongs_to :boat
  belongs_to :user
  belongs_to :user, through: :boat

  validates :start_at, :end_at, presence: true
end
