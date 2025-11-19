class MypageController < ApplicationController
  def show
    # 最新の記録から順に取得
    @recent_records = CheckinoutRecord.where(user_id: current_user.id)
                                    .order(checkin_time: :desc)
                                    .page(params[:page])
                                    .per(10)

    # 今月/今週の統計（サービスに委譲）
    @monthly_stats = CheckinoutStatsService.monthly_stats(current_user)
    @weekly_stats = CheckinoutStatsService.weekly_stats(current_user)

    # 今日の記録
    @today_record = find_today_record

    # 最近の気分記録
    @recent_moods = if current_user.respond_to?(:moods)
                      current_user.moods.includes(:checkinout_record).recent.limit(10)
    else
      []
    end
  end

  private

  def find_today_record
    current_user.checkinout_records.find_by(
      checkin_time: Date.current.beginning_of_day..Date.current.end_of_day,
      checkout_time: nil
    )
  end
end
