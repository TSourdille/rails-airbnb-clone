class BoatsController < ApplicationController
  def new
    @user = current_user
    @boat = @user.boats.new
  end
  def create
    user = current_user
    boat = user.boats.new(boat_params)
    if boat.save
      flash[:notice] = "Your boat has been added to our listing!"
      redirect_to root_path # TODO: boat
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
