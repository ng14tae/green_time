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
      # 今日のチェックインが既にある場合
      redirect_to checkin_path, notice: "既にチェックイン中です。まずチェックアウトしてください。"
    else
      # 新規チェックインを作成
      @today_record = current_user.checkinout_records.create!(checkin_time: Time.current)
      @notice_message = "チェックインしました"
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkin_path, notice: @notice_message } # HTMLでも対応
    end
  end

  def checkout_page
    # 今日の未チェックアウトの記録を取得
    @today_record = current_user.checkinout_records
                                .where(checkin_time: Time.zone.now.all_day, checkout_time: nil)
                                .order(checkin_time: :desc)
                                .first

    if @today_record.nil?
      redirect_to checkin_path, notice: "チェックアウトできる記録がありません"
    end
  end

  def checkout
    current_record = current_user.checkinout_records
                                  .where(checkout_time: nil)
                                  .order(checkin_time: :desc)
                                  .first

    if current_record
      current_record.update(checkout_time: Time.current)
      @notice_message = "チェックアウトしました"
    else
      @notice_message = "チェックアウトできる記録がありません"
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkin_path, notice: @notice_message }
    end
  end


  private

  def set_today_record
    @today_record = find_today_record
  end

  def find_today_record
    current_user.checkinout_records.find_by(
      checkin_time: Date.current.beginning_of_day..Date.current.end_of_day,
      checkout_time: nil
    )
  end
end
