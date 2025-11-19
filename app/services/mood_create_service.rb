class MoodCreateService
  Result = Struct.new(:success, :mood, :errors, :show_mood_success, :show_comment_success, :complete, keyword_init: true)

  def initialize(record:, user:, params: {})
    @record = record
    @user = user
    @params = params || {}
  end

  def call
    mood = @record.mood || @record.build_mood(user_id: @user.id)

    mood.feeling = @params[:feeling] if @params[:feeling].present?
    mood.comment = @params[:comment] if @params[:comment].present?

    if mood.save
      show_mood = mood.feeling.present?
      show_comment = mood.comment.present?
      complete = show_mood && show_comment

      Result.new(
        success: true,
        mood: mood,
        errors: [],
        show_mood_success: show_mood,
        show_comment_success: show_comment,
        complete: complete
      )
    else
      Result.new(success: false, mood: mood, errors: mood.errors.full_messages)
    end
  end
end
