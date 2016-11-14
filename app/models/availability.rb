class Availability < ApplicationRecord
  belongs_to :boat

  validates :start_at, :end_at, presence: true
end
