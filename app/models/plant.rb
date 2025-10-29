class Plant < ApplicationRecord
  belongs_to :user
  validates :plant_name, allow_blank: true, length: { maximum: 20 }

  def display_name
    plant_name.presence || "MIDORI"
  end
end
