class Mood < ApplicationRecord
  belongs_to :user
  belongs_to :checkinout_record

  EMOJI_LABELS = {
    "happy"   => { emoji: "😊", label: "良い", value: 3 },
    "neutral" => { emoji: "😐", label: "普通", value: 2 },
    "sad"     => { emoji: "😢", label: "悪い", value: 1 }
  }

  def mood_emoji
    EMOJI_LABELS[feeling][:emoji]
  end

  def value
    EMOJI_LABELS[feeling][:value]
  end

  def full_label
    "#{mood_emoji} #{EMOJI_LABELS[feeling][:label]}"
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
