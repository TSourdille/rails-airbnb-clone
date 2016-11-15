class BookingsController < ApplicationController
  def create
    boat = Boat.find(params[:boat_id])
    booking = boat.bookings.new(booking_params)
    if booking.save
      redirect_to boat
    else
      render 'boats/show'
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:start_at, :end_at)
  end
end
