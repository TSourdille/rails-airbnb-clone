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

  def update
    @boat = Boat.find(params[:boat_id])
    @booking = Booking.find(params[:id])
    if @booking.update(booking_params)
      flash[:notice] = "Review added!"
      redirect_to @boat
    else
      render 'boats/show'
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:start_at, :end_at, :user_review, :user_rating)
  end
end
