require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'アソシエーション' do
    it { is_expected.to have_many(:checkinout_records).dependent(:destroy) }
    it { is_expected.to have_many(:moods).dependent(:destroy) }
    it { is_expected.to have_one(:plant).dependent(:destroy) }
  end

  describe 'メソッド' do
    describe '#full_name' do
      let(:user) { build(:user, display_name: 'てー', nickname: nickname) }

      context 'nicknameがある場合' do
        let(:nickname) { 'Tee' }
        it 'nicknameを返すこと' do
          expect(user.full_name).to eq 'Tee'
        end
      end

      context 'nicknameがない場合' do
        let(:nickname) { nil }
        it 'display_nameを返すこと' do
          expect(user.full_name).to eq 'てー'
        end
      end
    end

    describe '#today_checkins' do
      let(:user) { create(:user) }

      before do
        create(:checkinout_record, user:, checkin_time: Time.current)
        create(:checkinout_record, user:, checkin_time: 1.day.ago)
      end

      it '今日のチェックインのみ取得できること' do
        expect(user.today_checkins.count).to eq 1
        expect(user.today_checkins.first.checkin_time.to_date).to eq Time.current.to_date
      end
    end
  end

  describe 'コールバック' do
    it '作成時にplantが自動生成されること' do
      user = create(:user)
      expect(user.plant).to be_present
      expect(user.plant.user).to eq user
    end
  end
end
