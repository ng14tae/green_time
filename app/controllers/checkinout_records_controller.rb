class CheckinoutRecordsController < ApplicationController
  def checkin_page
    # 未チェックアウトの最新レコード
    @current_record = current_user.checkinout_records
                                  .where(checkout_time: nil)
                                  .order(checkin_time: :desc)
                                  .first

    # 今日チェックインした場合だけ today 表示にセット
    @today_record = @current_record if @current_record&.checkin_time&.to_date == Date.current
  end

  def checkin
    # 未チェックアウトレコードがあればチェックイン不可
    ongoing = current_user.checkinout_records.where(checkout_time: nil).order(checkin_time: :desc).first

    if ongoing.present?
      @today_record = ongoing if ongoing.checkin_time.to_date == Date.current
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to checkin_path, notice: "既にチェックイン中です。まずチェックアウトしてください。" }
      end
      return
    end

    # 新規チェックイン作成
    @current_record = current_user.checkinout_records.create!(checkin_time: Time.current)
    @today_record = @current_record if @current_record.checkin_time.to_date == Date.current

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkin_path, notice: "チェックインしました" }
    end
  end

  def checkout_page
    # 未チェックアウトの最新レコード
    @current_record = current_user.checkinout_records
                                  .where(checkout_time: nil)
                                  .order(checkin_time: :desc)
                                  .first

    if @current_record.nil?
      redirect_to checkin_path, notice: "チェックアウトできる記録がありません"
    end
  end

  def checkout
    @current_record = current_user.checkinout_records
                                  .where(checkout_time: nil)
                                  .order(checkin_time: :desc)
                                  .first

    if @current_record
      @current_record.update!(checkout_time: Time.current)

      # 今日表示が必要な場合だけ today_record にセット
      @today_record = @current_record if @current_record.checkin_time.to_date == Date.current

      redirect_to mypage_path, notice: "チェックアウトしました"
    else
      redirect_to checkin_path, notice: "チェックアウトできる記録がありません"
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
