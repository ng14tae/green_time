module MoodsHelper
  FEELING_MAP = {
    "happy" => { label: "😊 良い", value: 3 },
    "neutral" => { label: "😐 普通", value: 2 },
    "sad" => { label: "😢 悪い", value: 1 }
  }

  def mood_data_for_pie(mood_counts)
    mood_counts
      .reject { |feeling, _| feeling.nil? }
      .transform_keys { |feeling| FEELING_MAP[feeling][:label] || feeling }
  end

  # 🎯 ハッシュ形式 + デバッグ情報付き
  def mood_data_for_recent(moods)
    # 🔧 空の場合の対応
    return { "気分推移" => { "データなし" => 0 } } if moods.empty?

    result = {}

    moods.each_with_index do |mood, i|
      date_label = "#{i + 1}回目 (#{mood.created_at.in_time_zone('Asia/Tokyo').strftime('%m/%d')})"
      value = case mood.feeling
              when "sad" then 1
              when "neutral" then 2
              when "happy" then 3
              else 0
              end

      result[date_label] = value

      # 🆕 デバッグログ（開発環境のみ）
      Rails.logger.info "#{i + 1}: #{date_label} => #{value} (feeling: #{mood.feeling})" if Rails.env.development?
    end

    final_result = { "気分推移" => result }
    Rails.logger.info "最終データ: #{final_result}" if Rails.env.development?

    final_result
  end
end