class BoatsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @boats = Boat.all
  end

  def show
    @boat = Boat.find(params[:id])
    @user = current_user
    @bookings = Booking.all
    @booking = @boat.bookings.new
  end

  def new
    @user = current_user
    @boat = @user.boats.new
  end

  def create
    user = current_user
    boat = user.boats.new(boat_params)
    if boat.save
      flash[:notice] = "Your boat has been added to our listing!"
      redirect_to boat
    else
      render 'new'
    end
  end

  private

  def boat_params
    params.require(:boat).permit(
    :boat_type,
    :name,
    :city,
    :capacity,
    :description,
    :specs,
    :equipment,
    :day_rate,
    photos: []
    )
  end
end
