class MypagesController < ApplicationController
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
    @today_status = detect_today_status

    # 最近の気分記録
    @recent_moods = if current_user.respond_to?(:moods)
                      current_user.moods.includes(:checkinout_record).recent.limit(10)
    else
      []
    end
  end

  private

  def detect_today_status
    ongoing = current_user.checkinout_records.where(checkout_time: nil)
                                            .order(checkin_time: :desc)
                                            .first

    return { status: :ongoing, record: ongoing } if ongoing.present?

    # 今日の活動を1秒でも含むレコードを探す
    today_range = Time.current.beginning_of_day..Time.current.end_of_day

    completed_today = current_user.checkinout_records
                                  .where(
                                    "(checkin_time <= ?) AND (checkout_time >= ?)",
                                    today_range.end,
                                    today_range.begin
                                  )
                                  .where.not(checkout_time: nil)
                                  .order(checkout_time: :desc)
                                  .first

    return { status: :completed, record: completed_today } if completed_today

    { status: :none }
  end
end
