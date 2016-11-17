class Booking < ApplicationRecord
  belongs_to :boat
  belongs_to :user
  validate :booking_period_not_overlapped

  validates :start_at, :boat_id, :user_id, :end_at, presence: true

  private

  def booking_period_not_overlapped
    unless Booking.where(
      '(start_at <= ? AND end_at >= ?) OR (start_at >= ? AND start_at <= ?)',
      start_at, start_at,
      start_at, end_at
      ).empty?
      errors.add(:start_at, 'Invalid period.')
    end
  end
end
