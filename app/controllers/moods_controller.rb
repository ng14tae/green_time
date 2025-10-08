class MoodsController < ApplicationController
  before_action :set_checkinout_record

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
          # 部分更新で状態に応じた表示
          render turbo_stream: turbo_stream.update("mood-checker") do
            if @mood.feeling.present? && @mood.comment.present?
              # 両方完了した場合
              render partial: "mood_complete", locals: { mood: @mood }
            else
              # 一部完了した場合（状態表示付きでフォーム継続）
              render partial: "mood_checker", locals: {
                record: @checkinout_record,
                show_mood_success: @mood.feeling.present?,
                show_comment_success: @mood.comment.present?
              }
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

  private

  def set_checkinout_record
    @checkinout_record = current_user.checkinout_records.find(params[:checkinout_record_id])
  end

  def mood_params
    params.require(:mood).permit(:feeling, :comment)
  end
end
