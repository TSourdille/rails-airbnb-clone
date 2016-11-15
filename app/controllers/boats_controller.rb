class BoatsController < ApplicationController
  def new
    @user = current_user
    @boat = @user.boats.new
  end
  def create
    user = current_user
    boat = user.boats.new(boat_params)
    if boat.save
      redirect_to root_path # TODO: boat
      # TODO: flash success
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
    :day_rate
    )
  end
end
