module CheckinoutRecordsHelper
  def time_diff(start_time, end_time)
    diff_seconds = (end_time - start_time).to_i
    hours = diff_seconds / 3600
    minutes = (diff_seconds % 3600) / 60

    "#{hours}時間#{minutes}分"
  end
end