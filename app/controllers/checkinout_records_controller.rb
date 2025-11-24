class CheckinoutRecordsController < ApplicationController
  def checkin_page
    # 勤務中レコード（未チェックアウト）
    @current_record = current_user.checkinout_records
                                  .where(checkout_time: nil)
                                  .order(checkin_time: :desc)
                                  .first

    # 今日新しくチェックインしている場合だけ today 表示に使う
    @today_record =
      if @current_record&.checkin_time&.to_date == Date.current
        @current_record
      else
        nil
      end

    # ※ 夜勤の場合（昨日の記録）は @current_record はあるが @today_record は nil
    # → ビュー側で “チェックイン済み” 表示、チェックインボタン無効
  end

  def checkin
    ongoing = current_user.checkinout_records.where(checkout_time: nil).first

    if ongoing.present?
      # Turbo用：チェックイン済み表示に戻す
      @today_record = ongoing if ongoing.checkin_time.to_date == Date.current
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to checkin_path, notice: "既にチェックイン中です。まずチェックアウトしてください。" }
      end
      return
    end

    # チェックイン作成
    @today_record = current_user.checkinout_records.create(checkin_time: Time.current)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkin_path, notice: "チェックインしました" }
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
    ongoing = current_user.checkinout_records.where(checkout_time: nil).first

    if ongoing.present?
      ongoing.update(checkout_time: Time.current)
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
