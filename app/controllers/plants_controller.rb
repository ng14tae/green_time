class PlantsController < ApplicationController
  before_action :authenticate_user_with_line_support!
  before_action :require_line_login         # LINE認証必須
  before_action :set_plant

  def index
  end

  def update
    if @plant.update(plant_params)
      redirect_to plants_path, notice: "#{@plant.display_name}に名前を変更しました🌱"
    else
      render :index
    end
  end

  private

  def set_plant
    @plant = current_user.plant || Plant.create!(user: current_user)
  end

  def plant_params
    params.require(:plant).permit(:plant_name)
  end
end
