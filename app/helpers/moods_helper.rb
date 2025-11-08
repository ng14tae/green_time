# app/helpers/moods_helper.rb
module MoodsHelper
  FEELING_LABELS = {
    "happy" => "😊 良い",
    "neutral" => "😐 普通",
    "sad" => "😢 悪い"
  }.freeze

  def mood_data_for_pie(mood_counts)
    mood_counts
      .reject { |feeling, _| feeling.nil? }
      .transform_keys { |feeling| FEELING_LABELS[feeling] || feeling }
  end

  # グラフ用データ + 日時情報を保持
  def mood_data_for_recent(moods)
    result = Hash.new { |h, k| h[k] = [] }

    moods.each do |mood|
      label = FEELING_LABELS[mood.feeling]
      next if label.nil?

      time = mood.created_at.in_time_zone('Asia/Tokyo').strftime("%m/%d %H:%M")
      result[label] << [time, 1]
    end

    Rails.logger.info "=== mood_data_for_recentの戻り値 ==="
    Rails.logger.info result.inspect  # ✅ 正しい
    result
  end
end
