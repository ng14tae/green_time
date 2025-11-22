class CheckinoutRecordsController < ApplicationController
  def checkin_page
    # チェックイン専用ページ
    @today_record = find_today_record
    @current_record = current_user.checkinout_records.find_by(checkout_time: nil)
  end

  def checkin
    # 最新の未チェックアウトレコードを確認
    current_record = current_user.checkinout_records
                                .where(checkout_time: nil)
                                .order(checkin_time: :desc)
                                .first

    if current_record.present?
      redirect_to checkin_path, notice: "既にチェックイン中です。まずチェックアウトしてください。"
      return
    end

    # 新規チェックインを作成
    @today_record = current_user.checkinout_records.create(checkin_time: Time.current)

    @notice_message = if @today_record.persisted?
                        "チェックインしました"
                      else
                        @today_record.errors.full_messages.join(", ")
                      end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkin_path, notice: @notice_message }
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

    redirect_to mypage_path, notice: @notice_message
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
