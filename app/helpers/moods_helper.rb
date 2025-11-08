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
    {
    "気分推移" => moods.map.with_index(1) do |mood, i|
      date_label = "#{i}回目 (#{mood.created_at.strftime("%m/%d")})"
      value = case mood.feeling
              when "sad" then 1
              when "neutral" then 2
              when "happy" then 3
              else 0
              end
      [date_label, value.to_i]
    end
  }
  end
end
