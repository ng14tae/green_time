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
    moods.map do |mood|
      {
        name: mood.created_at.strftime("%m/%d"),
        value: mood.value,
        label: mood.full_label
      }
    end
  end
end
