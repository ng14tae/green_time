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
    result = {}

    moods.each do |mood|
      feeling_label = FEELING_LABELS[mood.feeling]
      next if feeling_label.nil?

      # X軸ラベル: "11/07 15:30"
      datetime_label = mood.created_at.in_time_zone('Asia/Tokyo').strftime("%m/%d %H:%M")

      result[feeling_label] ||= {}
      result[feeling_label][datetime_label] = 1
    end

    result
  end
end