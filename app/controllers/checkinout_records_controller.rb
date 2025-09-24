class CheckinoutRecordsController < ApplicationController
  before_action :require_login
  before_action :set_current_user_record, only: [:show, :checkin, :checkout]

  def index
    @records = current_user.checkinout_records.recent.includes(:user)
    @today_record = current_user.checkinout_records.today.first
    @can_checkin = @today_record.nil?
    @can_checkout = @today_record&.checkout_time.nil?
  end

  def show
    @record = current_user.checkinout_records.find(params[:id])
  end

  def checkin
    @today_record = current_user.checkinout_records.today.first

    if @today_record.present?
      redirect_to checkinout_records_path, alert: "今日は既にチェックインしています"
      return
    end

    @record = current_user.checkinout_records.build(checkin_time: Time.current)

    if @record.save
      redirect_to checkinout_records_path, notice: "チェックインしました！"
    else
      redirect_to checkinout_records_path, alert: "チェックインに失敗しました"
    end
  end

  def checkout
    @today_record = current_user.checkinout_records.today.first

    unless @today_record
      redirect_to checkinout_records_path, alert: "チェックイン記録がありません"
      return
    end

    if @today_record.checked_out?
      redirect_to checkinout_records_path, alert: "既にチェックアウトしています"
      return
    end

    if @today_record.update(checkout_time: Time.current)
      redirect_to checkinout_records_path, notice: "チェックアウトしました！お疲れ様でした！"
    else
      redirect_to checkinout_records_path, alert: "チェックアウトに失敗しました"
    end
  end

  private

  def set_current_user_record
    @today_record = current_user.checkinout_records.today.first
  end
end
