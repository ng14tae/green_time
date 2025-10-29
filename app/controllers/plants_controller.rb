class PlantsController < ApplicationController
  before_action :authenticate_user!

  def index
    @plant = current_user.plant || Plant.new
  end

  def create
    @plant = Plant.new(plant_params)
    if @plant.save
      current_user.update(plant: @plant)
      redirect_to plants_path, notice: "名前をつけました🌱"
    else
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @plant = current_user.plant
  end

  def update
    @plant = current_user.plant
    if @plant.update(plant_params)
      redirect_to plants_path, notice: "名前を変更しました🌱"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:plant_name)
  end
end
