class Booking < ApplicationRecord
  belongs_to :boat
  belongs_to :user

  validates :start_at, :boat_id, :user_id, :end_at, presence: true
  validate :booking_overlapped_first, :booking_overlapped_last, on: :create

  def booking_overlapped_first
    unless self.boat.bookings.where(
      '(start_at <= ? AND end_at >= ?)',
      start_at, start_at
      ).empty?
      errors.add(:start_at, '')
    end
  end
  def booking_overlapped_last
    unless self.boat.bookings.where(
      '(start_at >= ? AND start_at <= ?)',
      start_at, end_at
      ).empty?
      errors.add(:end_at, '')
    end
  end
end
