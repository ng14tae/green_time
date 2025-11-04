class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # LIFF認証用バリデーション
  validates :line_user_id, presence: true, uniqueness: true, allow_nil: true
  validates :nickname, length: { maximum: 10 }

  # アソシエーション
  has_many :checkinout_records, dependent: :destroy
  has_one :plant, dependent: :destroy
  has_many :moods, dependent: :destroy

  # 表示名のロジック
  def full_name
    nickname.present? ? nickname : display_name
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
