class CheckinoutRecord < ApplicationRecord
  # アソシエーション
  belongs_to :user

  # バリデーション
  validates :checkin_time, presence: true
  validates :user_id, presence: true
  validate :checkout_after_checkin

  # スコープ
  scope :recent, -> { order(checkin_time: :desc) }
  scope :today, -> { where(checkin_time: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :checked_out, -> { where.not(checkout_time: nil) }
  scope :not_checked_out, -> { where(checkout_time: nil) }

  # メソッド
  def checked_out?
    checkout_time.present?
  end

  def working_duration
    return nil unless checked_out?
    ((checkout_time - checkin_time) / 1.hour).round(2)
  end

  def formatted_checkin_time
    checkin_time.strftime("%H:%M")
  end

  def formatted_checkout_time
    return "未チェックアウト" unless checked_out?
    checkout_time.strftime("%H:%M")
  end

  private

  def checkout_after_checkin
    return unless checkout_time && checkin_time

    if checkout_time <= checkin_time
      errors.add(:checkout_time, "はチェックイン時刻より後である必要があります")
    end
  end
end
