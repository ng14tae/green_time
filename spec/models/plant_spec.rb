require 'rails_helper'
require 'securerandom'

RSpec.describe Plant, type: :model do
  describe 'アソシエーション' do
    it 'user に属していること' do
      assoc = Plant.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe 'バリデーションとメソッド' do
    it 'plant_name は最大20文字' do
      p = Plant.new(plant_name: 'a' * 21)
      expect(p).not_to be_valid
      expect(p.errors[:plant_name]).to be_present
    end

    it '#display_name は plant_name がなければ MIDORI を返す' do
      p = Plant.new(plant_name: nil)
      expect(p.display_name).to eq 'MIDORI'
      p2 = Plant.new(plant_name: 'Greenie')
      expect(p2.display_name).to eq 'Greenie'
    end
  end
end
