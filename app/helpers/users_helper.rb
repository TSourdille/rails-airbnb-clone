module UsersHelper

  def bookings_by_time(bookings)
    past_bookings = bookings.select { |b| b.end_at < Date.today }
    future_bookings = bookings.select { |b| b.start_at > Date.today }
    present_bookings = bookings.select do |b|
      b.start_at <= Date.today && b.end_at >= Date.today || b.start_at >= Date.today && b.start_at <= Date.today
    end
    {
      past: past_bookings,
      future: future_bookings,
      present: present_bookings
    }
  end
end
