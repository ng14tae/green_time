class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # LIFF認証用バリデーション
  # validates :line_user_id, presence: true, uniqueness: true
  # validates :display_name, length: { maximum: 255 }
  # validates :nickname, length: { maximum: 255 }

  # アソシエーション
  has_many :checkinout_records, dependent: :destroy
  belongs_to :plant, optional: true  # plant_idはnull許可のため

  # plant登録時のスコープ
  # scope :with_plant, -> { where.not(plant_id: nil) }
  # scope :without_plant, -> { where(plant_id: nil) }

  # メソッド
  def full_name
    nickname.present? ? nickname : display_name
  end

  def today_checkins
    checkinout_records.where(
      checkin_time: Time.current.beginning_of_day..Time.current.end_of_day
    )
  end
end
