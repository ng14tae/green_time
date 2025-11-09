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

  def mood_data_for_recent(moods)
    moods.map.with_index(1) do |mood, i|
      [ "#{i}回目 (#{mood.created_at.strftime("%m/%d")})", FEELING_MAP[mood.feeling][:value] ]
    end
  end
end
