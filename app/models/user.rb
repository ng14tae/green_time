class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # LIFF認証用バリデーション
  validates :line_user_id, uniqueness: true, allow_nil: true
  validates :nickname, length: { maximum: 10 }, allow_blank: true
  validates :display_name, length: { maximum: 50 }, allow_blank: true

  # アソシエーション
  has_many :checkinout_records, dependent: :destroy
  has_one :plant, dependent: :destroy
  has_many :moods, dependent: :destroy

  def self.find_or_create_by_line(line_user_id, display_name)
    user = find_by(line_user_id: line_user_id)
    return user if user

    # Deviseの制約を満たしつつLINEユーザーを作成
    create!(
      line_user_id: line_user_id,
      display_name: display_name,
      email: "line_#{line_user_id}@temp.local",
      password: SecureRandom.hex(20)
    )
  end

  def display_name_for_user
    nickname.presence || display_name || "ゲスト"
  end

  def needs_nickname_setup?
    nickname.blank?
  end

  # LINE認証ユーザーかどうかを判定
  def line_user?
    line_user_id.present?
  end

  def today_checkins
    checkinout_records.where(
      checkin_time: Time.current.beginning_of_day..Time.current.end_of_day
    )
  end

  after_create :create_plant

  private

  def create_plant
    Plant.create!(user: self)
  end
end
