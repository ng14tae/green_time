class MoodsController < ApplicationController

  before_action :set_checkinout_record

  def mood_check
    render json: { recorded: @checkinout_record.mood.present? }
  end

  def create
    if @checkinout_record.mood.present?
      render json: { status: 'already_recorded' }
      return
    end

    @mood = @checkinout_record.build_mood(mood_params.merge(user_id: current_user.id))

    if @mood.save
      render json: {
        status: 'success',
        mood_emoji: @mood.mood_emoji,
        comment: @mood.comment
      }
    else
      render json: { status: 'error', errors: @mood.errors.full_messages }
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
