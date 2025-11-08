# app/helpers/moods_helper.rb
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

  # グラフ用データ + 日時情報を保持
  def mood_data_for_recent(moods)
    data = moods.map.with_index(1) do |mood, idx|
      label = "#{idx}回目\n(#{mood.created_at.in_time_zone('Asia/Tokyo').strftime('%m/%d %H:%M')})"
      value = FEELING_MAP[mood.feeling][:value]
      [label, value]
    end

    { "気分推移" => data }
  end
end
