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
    data = {}

    moods.each_with_index do |mood, i|
      date_label = "#{i + 1}回目 (#{mood.created_at.in_time_zone('Asia/Tokyo').strftime('%m/%d')})"
      value = case mood.feeling
              when "sad" then 1
              when "neutral" then 2
              when "happy" then 3
              else 0
              end

      data[date_label] = value
    end

    { "気分推移" => data }
  end
end