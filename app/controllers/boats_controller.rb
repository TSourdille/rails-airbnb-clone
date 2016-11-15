class BoatsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @boats = Boat.all
  end

  def show
    @boat = Boat.find(params[:id])
  end
end

