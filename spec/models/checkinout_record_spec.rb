require 'rails_helper'
require 'securerandom'

RSpec.describe CheckinoutRecord, type: :model do
  describe 'アソシエーション' do
    it 'user に属していること' do
      assoc = CheckinoutRecord.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'mood を has_one で持ち、dependent: :destroy であること' do
      assoc = CheckinoutRecord.reflect_on_association(:mood)
      expect(assoc.macro).to eq :has_one
      expect(assoc.options[:dependent]).to eq :destroy
    end
  end

  describe 'バリデーションとカスタムバリデーション' do
    it 'checkin_time がなければ無効' do
      rec = CheckinoutRecord.new(user_id: 1, checkin_time: nil)
      expect(rec).not_to be_valid
      expect(rec.errors[:checkin_time]).to be_present
    end

    it 'checkout_time は checkin_time より後でなければならない' do
      user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
      rec = CheckinoutRecord.new(user: user, checkin_time: Time.current, checkout_time: 1.hour.ago)
      expect(rec).not_to be_valid
      expect(rec.errors[:checkout_time]).to be_present
    end
  end

  describe 'スコープ / メソッド' do
    let(:user) { User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password') }

    before do
      @today = CheckinoutRecord.create!(user: user, checkin_time: Time.current)
      @yesterday = CheckinoutRecord.create!(user: user, checkin_time: 1.day.ago)
    end

    it '.today は今日のレコードのみ返す' do
      expect(CheckinoutRecord.today).to include(@today)
      expect(CheckinoutRecord.today).not_to include(@yesterday)
    end

    it '.recent は降順に並ぶ' do
      expect(CheckinoutRecord.recent.first).to eq @today
    end

    it '#checked_out? と #working_duration の挙動' do
      rec = CheckinoutRecord.create!(user: user, checkin_time: 2.hours.ago, checkout_time: Time.current)
      expect(rec.checked_out?).to be true
      expect(rec.working_duration).to be_within(0.01).of(2.0)
    end

    it '#formatted_checkin_time / #formatted_checkout_time の挙動' do
      rec = CheckinoutRecord.create!(user: user, checkin_time: Time.current)
      expect(rec.formatted_checkin_time).to match(/\d{2}:\d{2}/)
      expect(rec.formatted_checkout_time).to eq '未チェックアウト'
    end

    it '#mood_emoji / #has_mood? の挙動' do
      rec = CheckinoutRecord.create!(user: user, checkin_time: Time.current)
      expect(rec.has_mood?).to be false
      Mood.create!(user: user, checkinout_record: rec, feeling: 'happy')
      expect(rec.has_mood?).to be true
      # CheckinoutRecord#mood_emoji returns the mood.feeling string (not the emoji)
      expect(rec.mood_emoji).to eq 'happy'
    end
  end
end
