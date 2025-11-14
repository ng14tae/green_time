class MoodsController < ApplicationController
  before_action :set_checkinout_record, only: [ :mood_check, :create ]

  def mood_check
    render json: { recorded: @checkinout_record.mood.present? }
  end

  def create
    @mood = @checkinout_record.mood || @checkinout_record.build_mood(user_id: current_user.id)

    if mood_params[:feeling].present?
      @mood.feeling = mood_params[:feeling]
    end

    if mood_params[:comment].present?
      @mood.comment = mood_params[:comment]
    end

    if @mood.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("mood-checker") do
            if @mood.feeling.blank? || @mood.comment.blank?
              # 一部完了した場合（状態表示付きでフォーム継続）
              render partial: "mood_checker", locals: {
                record: @checkinout_record,
                show_mood_success: @mood.feeling.present?,
                show_comment_success: @mood.comment.present?
              }
            else
              # 両方完了した場合
              render partial: "mood_complete", locals: { mood: @mood }
            end
          end
        end
        format.json do
          render json: {
            status: "success",
            mood_emoji: @mood.mood_emoji,
            comment: @mood.comment
          }
        end
      end
    else
      # エラー処理
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("mood-checker") do
            content_tag(:div, @mood.errors.full_messages.join(", "),
                        class: "alert alert-error")
          end
        end
        format.json { render json: { status: "error", errors: @mood.errors.full_messages } }
      end
    end
  end

  def analytics
    if current_user.moods.empty?
      redirect_to root_path, notice: "まずは気分を記録してみましょう！"
      return
    end

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
