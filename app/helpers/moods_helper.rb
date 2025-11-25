module MoodsHelper
  FEELING_MAP = {
    "happy"   => { label: "😊 良い", value: 3 },
    "neutral" => { label: "😐 普通", value: 2 },
    "sad"     => { label: "😢 悪い", value: 1 }
  }

  # 円グラフ用
  def mood_data_for_pie(mood_counts)
    FEELING_MAP.keys.map do |key|
      [
        FEELING_MAP[key][:label],
        mood_counts[key].to_i
      ]
    end.to_h
  end

  # 折れ線グラフ用（数値）
  def mood_data_for_recent(moods)
    moods.map do |m|
      [ m.created_at.strftime("%m/%d"), FEELING_MAP[m.feeling][:value] ]
    end
  end
end
