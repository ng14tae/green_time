class PlantsController < ApplicationController
  before_action :authenticate_user!

  def index
    @plant = current_user.plant || Plant.new
  end

  def create
    @plant = Plant.new(plant_params)
    if @plant.save
      current_user.update(plant: @plant)
      redirect_to checkin_path, notice: "名前をつけました🌱"
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:plant_name)
  end
end
