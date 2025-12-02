class MoodsController < ApplicationController
  before_action :set_checkinout_record, only: [ :mood_check, :create ]

  def mood_check
    render json: { recorded: @checkinout_record.mood.present? }
  end

  def create
    if @checkinout_record.checked_out?
      respond_to do |format|
        format.turbo_stream do
          ts = turbo_stream.update("mood-checker") do
            content_tag(:div, "チェックアウト後は編集できません", class: "alert alert-error")
          end
          render turbo_stream: ts, status: :forbidden
        end
        format.json { render json: { status: "error", message: "checked out" }, status: :forbidden }
      end
      return
    end

    service = MoodCreateService.new(record: @checkinout_record, user: current_user, params: mood_params.to_h)
    result = service.call

    unless result.success
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("mood-checker") do
            content_tag(:div, result.errors.join(", "), class: "alert alert-error")
          end
        end
        format.json { render json: { status: "error", errors: result.errors } }
      end
      return
    end

    # success
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("mood-checker") do
          if result.complete
            render partial: "mood_complete", locals: { mood: result.mood }
          else
            render partial: "mood_checker", locals: {
              record: @checkinout_record,
              show_mood_success: result.show_mood_success,
              show_comment_success: result.show_comment_success
            }
          end
        end
      end
      format.json do
        render json: {
          status: "success",
          mood_emoji: result.mood.mood_emoji,
          comment: result.mood.comment
        }
      end
    end
  end

  def analytics
    # 円グラフ用
    @mood_counts = current_user.moods.group(:feeling).count
    @mood_counts_for_pie = helpers.mood_data_for_pie(@mood_counts)

    # 直近30回分の折れ線グラフ用
    @recent_moods = current_user.moods
                                .where.not(feeling: nil)
                                .limit(30)
                                .order(created_at: :desc)
                                .reverse
    @recent_moods_chart_data = helpers.mood_data_for_recent(@recent_moods)

    Rails.logger.info "=== 最近の気分データ（チャート用） ==="
    Rails.logger.info @recent_moods_chart_data.inspect
  end

  private

  def set_checkinout_record
    @checkinout_record = current_user.checkinout_records.find(params[:checkinout_record_id])
  end

  def mood_params
    params.require(:mood).permit(:feeling, :comment)
  end
end
