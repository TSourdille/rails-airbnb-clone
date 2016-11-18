class BoatsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    if params[:destination].blank?
      @boats = Boat.all
      build_markers(boats_with_location(@boats))
    elsif Boat.near(params[:destination], 60).blank?
      flash[:alert] = "Pas de bateaux à #{params[:destination].capitalize} :("
      redirect_to root_path
    else
      @boats = Boat.near(params[:destination].capitalize, 60)
      build_markers(boats_with_location(@boats))
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
      render 'boats/new'
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
    :length,
    :beds,
    :image1,
    :image2,
    :image3,
    :latitude,
    :longitude,
    :equipment,
    :day_rate,
    photos: []
    )
  end

  def build_markers(boats)
    @hash = Gmaps4rails.build_markers(boats) do |boat, marker|
      marker.lat boat.latitude
      marker.lng boat.longitude
    end
  end

  def boats_with_location(boats)
    boats.where.not(latitude: nil, longitude: nil)
  end
end
