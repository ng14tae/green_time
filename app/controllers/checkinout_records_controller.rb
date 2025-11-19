class CheckinoutRecordsController < ApplicationController
  def checkin_page
    # チェックイン専用ページ
    @today_record = find_today_record
    @current_record = current_user.checkinout_records.find_by(checkout_time: nil)
  end

  def checkin
    # 今日のチェックイン記録を探す
    current_record = current_user.checkinout_records
      .where(checkout_time: nil)
      .where("DATE(checkin_time) = ?", Date.current)
      .first

    if current_record.present?
      redirect_to checkin_path, notice: "既にチェックイン中です。まずチェックアウトしてください。"
    else
      # 過去の未チェックアウト記録を自動クローズ
      old_unclosed = current_user.checkinout_records
        .where(checkout_time: nil)
        .where("DATE(checkin_time) < ?", Date.current)

      old_unclosed.update_all(checkout_time: Time.current)

      @today_record = current_user.checkinout_records.create!(checkin_time: Time.current)
      @notice_message = "チェックインしました"
    end

    # ★重要：リダイレクトを削除してTurbo Streamレスポンス
    respond_to do |format|
      format.turbo_stream
    end
  end

  def checkout_page
    # チェックアウト専用ページ
    @today_record = find_today_record
    redirect_to checkin_path if @today_record.blank?
  end

  def checkout
    today_start = Time.zone.today.beginning_of_day
    today_end = Time.zone.today.end_of_day

    current_record = current_user.checkinout_records
                                .where(checkout_time: nil)
                                .where(checkin_time: today_start..today_end)
                                .order(checkin_time: :desc)
                                .first

    if current_record
      current_record.update(checkout_time: Time.current)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkin_path, notice: "チェックアウトしました" }
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
