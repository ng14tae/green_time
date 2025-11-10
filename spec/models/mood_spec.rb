require 'rails_helper'
require 'securerandom'

RSpec.describe Mood, type: :model do
  describe 'アソシエーション' do
    it 'user に属していること' do
      assoc = Mood.reflect_on_association(:user)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'checkinout_record に属していること' do
      assoc = Mood.reflect_on_association(:checkinout_record)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe 'バリデーション' do
    it 'feeling の inclusion を検証する' do
      m = Mood.new(feeling: 'invalid')
      expect(m).not_to be_valid
      expect(m.errors[:feeling]).to be_present
    end

    it '同一 user に対して checkinout_record_id は一意であること' do
      user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
      rec = CheckinoutRecord.create!(user: user, checkin_time: Time.current)
      Mood.create!(user: user, checkinout_record: rec, feeling: 'happy')
      dup = Mood.new(user: user, checkinout_record: rec, feeling: 'neutral')
      expect(dup).not_to be_valid
      expect(dup.errors[:checkinout_record_id]).to be_present
    end

    it 'comment の長さ制限を検証する' do
      m = Mood.new(comment: 'a' * 141)
      expect(m).not_to be_valid
      expect(m.errors[:comment]).to be_present
    end
  end

  describe 'メソッド / スコープ' do
    it '#mood_emoji が対応する絵文字を返すこと' do
      expect(Mood.new(feeling: 'happy').mood_emoji).to eq '😊'
      expect(Mood.new(feeling: 'neutral').mood_emoji).to eq '😐'
      expect(Mood.new(feeling: 'sad').mood_emoji).to eq '😢'
    end

    it '.recent は降順で返すこと' do
      user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
  Mood.create!(user: user, checkinout_record: CheckinoutRecord.create!(user: user, checkin_time: 1.day.ago), feeling: 'happy')
  m2 = Mood.create!(user: user, checkinout_record: CheckinoutRecord.create!(user: user, checkin_time: Time.current), feeling: 'neutral')
  expect(Mood.recent.first).to eq m2
    end
  end
end
