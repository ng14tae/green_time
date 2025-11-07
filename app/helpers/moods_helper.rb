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
  def mood_chart_data(moods)
    # グラフデータ
    chart_data = {}
    # 日時情報（ツールチップ用）
    datetime_info = {}

    moods.each_with_index do |mood, index|
      feeling_label = FEELING_LABELS[mood.feeling]
      next if feeling_label.nil?

      label = "#{index + 1}回目"
      datetime = mood.created_at.in_time_zone('Asia/Tokyo').strftime("%Y年%m月%d日 %H:%M")

      chart_data[feeling_label] ||= {}
      chart_data[feeling_label][label] = 1

      datetime_info[label] = datetime
    end

    [chart_data, datetime_info]
  end
end