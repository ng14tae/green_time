class CheckinoutRecordsController < ApplicationController
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

  def smart_checkin
    # 現在チェックイン中（未チェックアウト）のレコードがあるかチェック
    current_checkin = current_user.checkinout_records.find_by(checkout_time: nil)

    if current_checkin
      # ①チェックイン済の場合 → 編集ページへ
      redirect_to edit_today_checkinout_records_path
    else
      # ②未チェックインの場合 → 新規チェックインページへ
      redirect_to checkin_page_checkinout_records_path
    end
  end

  def edit_today
    # ヘッダーからの再アクセス用
    @today_record = find_today_record
    @current_record = current_user.checkinout_records.find_by(checkout_time: nil)

    # 今日の記録がない場合は初回チェックイン画面へ
    unless @today_record.present?
      redirect_to checkin_checkinout_records_path, notice: "まずはチェックインしてください"
      nil
    end
  end

  def checkin_page
    # チェックイン専用ページ
    @today_record = find_today_record
    @current_record = current_user.checkinout_records.find_by(checkout_time: nil)
  end

  def checkin
    # 今日のチェックイン記録を探す
    current_record = current_user.checkinout_records
      .where(checkout_time: nil)
      .where('DATE(checkin_time) = ?', Date.current)
      .first

    if current_record.present?
      redirect_to checkin_path, notice: "既にチェックイン中です。まずチェックアウトしてください。"
    else
      # 過去の未チェックアウト記録を自動クローズ
      old_unclosed = current_user.checkinout_records
        .where(checkout_time: nil)
        .where('DATE(checkin_time) < ?', Date.current)

      old_unclosed.update_all(checkout_time: Time.current)

      # 新規チェックイン
      current_user.checkinout_records.create!(checkin_time: Time.current)
      redirect_to checkin_path, notice: "チェックインしました！"
    end
  end

  def smart_checkout
    current_record = current_user.checkinout_records.find_by(checkout_time: nil)

    if current_record.present?
      redirect_to checkout_page_checkinout_records_path
    else
      redirect_to mood_record_checkinout_records_path
    end
  end
    def checkout_page
      # チェックアウト専用ページ
      @today_record = find_today_record
      redirect_to checkin_page_checkinout_records_path if @today_record.blank?
    end

  def checkout
    # 今日のチェックイン記録を探す
    current_record = current_user.checkinout_records
      .where(checkout_time: nil)
      .where('DATE(checkin_time) = ?', Date.current)
      .first

    if current_record.present?
      current_record.update!(checkout_time: Time.current)
      redirect_to mood_record_checkinout_records_path,
                  notice: "チェックアウトしました！今日の気分を記録してみませんか？"
    else
      redirect_to checkin_path, alert: "今日のチェックイン記録が見つかりません"
    end
  end

  def mood_record
    @latest_record = current_user.checkinout_records.order(created_at: :desc).first

    unless @today_record
        redirect_to checkin_page_checkinout_records_path,
                    alert: "今日のチェックイン記録が見つかりません。先にチェックインしてください。"
        return
    end

    if @latest_record.present?
      # 気分記録ページを表示（ビューで@latest_recordを使用）
    else
      redirect_to checkin_page_checkinout_records_path, notice: "まずはチェックインしてください"
    end
  end

  def mypage
    # 最新の記録から順に取得
    @recent_records = CheckinoutRecord.where(user_id: current_user.id)
                                    .order(checkin_time: :desc)
                                    .page(params[:page])
                                    .per(10)

    # 今月の統計
    @monthly_stats = calculate_monthly_stats

    # 今週の統計
    @weekly_stats = calculate_weekly_stats

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

  # 今月の統計を計算
  def calculate_monthly_stats
    start_of_month = Time.current.beginning_of_month
    end_of_month = Time.current.end_of_month

    records = CheckinoutRecord.where(
      user_id: current_user.id,
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
      user_id: current_user.id,
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
