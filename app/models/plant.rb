class Plant < ApplicationRecord
  has_many :users, dependent: :nullify
  validates :plant_name, presence: true, length: { maximum: 50 }
end
