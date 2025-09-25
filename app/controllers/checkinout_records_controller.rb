class CheckinoutRecordsController < ApplicationController
  before_action :set_guest_user
  before_action :find_today_record, only: [ :index, :checkin_page, :checkout_page, :mypage ]

  def index
    # メインページ - 状態に応じてリダイレクト
    @today_record = find_today_record

    if @today_record.present?
      redirect_to checkout_page_checkinout_records_path
    else
      redirect_to checkin_page_checkinout_records_path
    end
  end

  def checkin_page
    # チェックイン専用ページ
    redirect_to checkout_page_checkinout_records_path if find_today_record.present?
  end

  def checkout_page
    # チェックアウト専用ページ
    @today_record = find_today_record
    redirect_to checkin_page_checkinout_records_path if @today_record.blank?
  end

  # ← 新しく追加するマイページアクション
  def mypage
    # 最新の記録から順に取得
    @recent_records = CheckinoutRecord.where(user_id: @current_user_id)
                                    .order(checkin_time: :desc)
                                    .limit(30) # 最新30件を表示

    # 今月の統計
    @monthly_stats = calculate_monthly_stats

    # 今週の統計
    @weekly_stats = calculate_weekly_stats

    # 今日の記録
    @today_record = find_today_record
  end

  def checkin
    CheckinoutRecord.create!(
      user_id: @current_user_id,
      checkin_time: Time.current
    )
    redirect_to checkout_page_checkinout_records_path, notice: "チェックインしました"
  end

  def checkout
    record = find_today_record
    record.update!(checkout_time: Time.current)
    redirect_to checkin_page_checkinout_records_path, notice: "チェックアウトしました"
  end

  private

  def set_guest_user
    @current_user_id = 1 # ゲストユーザーのID
  end

  def find_today_record
    @today_record = CheckinoutRecord.find_by(
      user_id: @current_user_id,
      checkin_time: Time.current.beginning_of_day..Time.current.end_of_day,
      checkout_time: nil
    )
  end

  # 今月の統計を計算
  def calculate_monthly_stats
    start_of_month = Time.current.beginning_of_month
    end_of_month = Time.current.end_of_month

    records = CheckinoutRecord.where(
      user_id: @current_user_id,
      checkin_time: start_of_month..end_of_month
    ).where.not(checkout_time: nil)

    {
      total_days: records.count,
      total_hours: calculate_total_hours(records),
      average_hours: calculate_average_hours(records)
    }
  end

  # 今週の統計を計算
  def calculate_weekly_stats
    start_of_week = Time.current.beginning_of_week
    end_of_week = Time.current.end_of_week

    records = CheckinoutRecord.where(
      user_id: @current_user_id,
      checkin_time: start_of_week..end_of_week
    ).where.not(checkout_time: nil)

    {
      total_days: records.count,
      total_hours: calculate_total_hours(records)
    }
  end

  # 総労働時間を計算
  def calculate_total_hours(records)
    total_seconds = records.sum do |record|
      (record.checkout_time - record.checkin_time).to_i
    end
    total_seconds / 3600.0 # 時間に変換
  end

  # 平均労働時間を計算
  def calculate_average_hours(records)
    return 0 if records.empty?
    calculate_total_hours(records) / records.count
  end
end
