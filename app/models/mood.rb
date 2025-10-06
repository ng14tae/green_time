class Mood < ApplicationRecord
  belongs_to :user
  belongs_to :checkinout_record

  def mood_emoji
    case feeling
    when 'happy' then '😊'
    when 'neutral' then '😐'
    when 'sad' then '😢'
    else '😊'
    end
  end

  validates :feeling, inclusion: {
    in: %w[happy neutral sad],
    message: "は有効な値を選択してください"
  }, allow_blank: true

  validates :checkinout_record_id, uniqueness: {
    scope: :user_id,
    message: "この記録にはすでに気分が登録されています"
  }

  # コメントの文字数制限
  validates :comment, length: { maximum: 140, message: "は140文字以内で入力してください" }

  # スコープを追加（マイページで使用）
  scope :recent, -> { order(created_at: :desc) }
end
