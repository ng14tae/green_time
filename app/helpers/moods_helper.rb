# app/helpers/moods_helper.rb
module MoodsHelper
  FEELING_MAP = {
    "happy" => { label: "😊 happy", value: 3 },
    "neutral" => { label: "😐 neutral", value: 2 },
    "sad" => { label: "😢 sad", value: 1 }
  }

  def mood_data_for_pie(mood_counts)
    mood_counts
      .reject { |feeling, _| feeling.nil? }
      .transform_keys { |feeling| FEELING_MAP[feeling][:label] || feeling }
  end

  # グラフ用データ + 日時情報を保持
  def mood_data_for_recent(moods)
    moods = moods.order(:created_at).last(30)

    data = moods.map.with_index(1) do |mood, idx|
      label = FEELING_MAP[mood.feeling][:label]
      value = FEELING_MAP[mood.feeling][:value]
      [
        "#{idx}回目\n(#{mood.created_at.strftime('%m/%d')})",
        value
      ]
    end

    # Chartkickは { "ラベル" => 配列 } の形式
    { "気分推移" => data }
  end
end
