class MoodsController < ApplicationController
  before_action :set_checkinout_record, except: [ :analytics ]
  before_action :authenticate_user!, only: [ :analytics ]

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
    # データが存在しない場合の処理
    if current_user.moods.empty?
      redirect_to root_path, notice: "まずは気分を記録してみましょう！"
      return
    end

    # 円グラフ
    @mood_counts = current_user.moods.group(:feeling).count

    # 折れ線グラフ
    @daily_moods = current_user.moods
                            .where("created_at >= ?", 7.days.ago)
                            .group_by_day(:created_at)
                            .group(:feeling)
                            .count
    # 週間推移データ
    @weekly_trend = current_user.moods
                              .where("created_at >= ?", 4.weeks.ago)
                              .group_by_week(:created_at)
                              .count
  end

  private

  def set_checkinout_record
    @checkinout_record = current_user.checkinout_records.find(params[:checkinout_record_id])
  end

  def mood_params
    params.require(:mood).permit(:feeling, :comment)
  end
end
