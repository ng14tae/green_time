require 'rails_helper'
require 'securerandom'

RSpec.describe User, type: :model do
  describe 'アソシエーション' do
    it 'checkinout_records は has_many で dependent: :destroy であること' do
      assoc = User.reflect_on_association(:checkinout_records)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:dependent]).to eq :destroy
    end

    it 'moods は has_many で dependent: :destroy であること' do
      assoc = User.reflect_on_association(:moods)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:dependent]).to eq :destroy
    end

    it 'plant は has_one で dependent: :destroy であること' do
      assoc = User.reflect_on_association(:plant)
      expect(assoc.macro).to eq :has_one
      expect(assoc.options[:dependent]).to eq :destroy
    end
  end

  describe 'メソッド' do
    describe '#display_name_for_user' do
      let(:user) { User.new(display_name: 'てー', nickname: nickname) }

      context 'nicknameがある場合' do
        let(:nickname) { 'Tee' }
        it 'nicknameを返すこと' do
          expect(user.display_name_for_user).to eq 'Tee'
        end
      end

      context 'nicknameがない場合' do
        let(:nickname) { nil }
        it 'display_nameを返すこと' do
          expect(user.display_name_for_user).to eq 'てー'
        end
      end

      context 'nicknameとdisplay_nameがない場合' do
        let(:user) { User.new(display_name: nil, nickname: nil) }
        it 'ゲストを返すこと' do
          expect(user.display_name_for_user).to eq 'ゲスト'
        end
      end
    end

    describe '#today_checkins' do
      let(:user) { User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password') }

      before do
        user.checkinout_records.create!(checkin_time: Time.current)
        user.checkinout_records.create!(checkin_time: 1.day.ago)
      end

      it '今日のチェックインのみ取得できること' do
        expect(user.today_checkins.count).to eq 1
        expect(user.today_checkins.first.checkin_time.to_date).to eq Time.current.to_date
      end
    end

    describe '.find_or_create_by_line' do
      it '既存の line_user_id があればそれを返す' do
        existing = User.create!(line_user_id: 'L123', display_name: '既存', email: "ex#{SecureRandom.hex(4)}@example.test", password: 'password')
        expect(User.find_or_create_by_line('L123', '何か')).to eq existing
      end

      it 'なければ新規作成すること' do
        user = User.find_or_create_by_line('L999', 'LINE太郎')
        expect(user).to be_persisted
        expect(user.line_user_id).to eq 'L999'
        # メールは内部で小文字化される場合があるため小文字で比較する
        expect(user.email.downcase).to start_with('line_l999@')
        expect(user.password).to be_present
      end
    end

    describe '#line_user?' do
      it 'line_user_id があれば true を返す' do
        u = User.new(line_user_id: 'L1')
        expect(u.line_user?).to be true
      end

      it 'なければ false' do
        u = User.new(line_user_id: nil)
        expect(u.line_user?).to be false
      end
    end

    describe '#needs_nickname_setup?' do
      it 'nickname が空なら true' do
        u = User.new(nickname: nil)
        expect(u.needs_nickname_setup?).to be true
      end

      it '存在すれば false' do
        u = User.new(nickname: 'taro')
        expect(u.needs_nickname_setup?).to be false
      end
    end
  end

  describe 'コールバック' do
    it '作成時にplantが自動生成されること' do
      user = User.create!(email: "u#{SecureRandom.hex(4)}@example.test", password: 'password')
      expect(user.plant).to be_present
      expect(user.plant.user).to eq user
    end
  end

  describe 'バリデーション' do
    it 'line_user_id は一意であること' do
      User.create!(line_user_id: 'L-A', email: "a#{SecureRandom.hex(3)}@example.test", password: 'password')
      dup = User.new(line_user_id: 'L-A', email: "b#{SecureRandom.hex(3)}@example.test", password: 'password')
      expect(dup).not_to be_valid
      expect(dup.errors[:line_user_id]).to be_present
    end

    it 'nickname は最大10文字であること' do
      u = User.new(nickname: 'a' * 11)
      expect(u).not_to be_valid
      expect(u.errors[:nickname]).to be_present
    end

    it 'display_name は最大50文字であること' do
      u = User.new(display_name: 'x' * 51)
      expect(u).not_to be_valid
      expect(u.errors[:display_name]).to be_present
    end
  end

  describe 'パスワード要否判定' do
    it 'LINEユーザーはパスワード不要になること' do
      u = User.new(line_user_id: 'L-1')
      expect(u.send(:password_required?)).to be false
    end

    it '通常ユーザーはパスワードが必要' do
      u = User.new(line_user_id: nil)
      expect(u.send(:password_required?)).to be true
    end
  end
end
