class BoatsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @boats = Boat.all
    if params[:destination].empty?
      @boats = Boat.all
    else params[:destination]
      @boats = Boat.near(params[:destination].capitalize, 60)
    end

    @boat_location = @boats.where.not(latitude: nil, longitude: nil)
    @hash = Gmaps4rails.build_markers(@boat_location) do |boat, marker|
      marker.lat boat.latitude
      marker.lng boat.longitude
    end
  end

  def show
    @boat = Boat.find(params[:id])
    @user = current_user
    @bookings = @boat.bookings
    @booking = Booking.new

    if @boat.longitude && @boat.latitude
      @hash = Gmaps4rails.build_markers(@boat) do |boat, marker|
        marker.lat boat.latitude
        marker.lng boat.longitude
      end
    end
  end

  def new
    @user = current_user
    @boat = @user.boats.new
  end

  def create
    @user = current_user
    @boat = @user.boats.new(boat_params)
    if @boat.save
      flash[:notice] = "Your boat has been added to our listing!"
      redirect_to @boat
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
