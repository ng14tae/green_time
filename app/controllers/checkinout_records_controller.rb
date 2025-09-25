class CheckinoutRecordsController < ApplicationController
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

  def checkin
    CheckinoutRecord.create!(
      user_id: guest_user_id,
      checkin_time: Time.current
    )
    redirect_to checkout_page_checkinout_records_path, notice: 'チェックインしました'
  end

  def checkout
    record = find_today_record
    record.update!(checkout_time: Time.current)
    redirect_to checkin_page_checkinout_records_path, notice: 'チェックアウトしました'
  end

  private

  def find_today_record
    CheckinoutRecord.find_by(
      user_id: guest_user_id,
      checkin_time: Time.current.beginning_of_day..Time.current.end_of_day,
      checkout_time: nil
    )
  end

  def guest_user_id
    1  # ← 修正: 固定のユーザーID
  end
end