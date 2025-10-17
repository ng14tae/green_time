module MoodsHelper
  def mood_data_for_pie(mood_counts)
    mood_counts.transform_keys do |feeling|
      case feeling
      when "happy" then "😊 良い"
      when "neutral" then "😐 普通"
      when "sad" then "😢 悪い"
      else feeling
      end
    end
  end

  def mood_data_for_daily(daily_moods)
    # 日別データを整理
    result = {}

    daily_moods.each do |(date, feeling), count|
      feeling_label = case feeling
      when "happy" then "😊 良い"
      when "neutral" then "😐 普通"
      when "sad" then "😢 悪い"
      end

      result[feeling_label] ||= {}
      result[feeling_label][date] = count
    end

    result
  end
end