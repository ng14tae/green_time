class LineSessionsController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :create ]
  protect_from_forgery except: :create

  def create
    line_user_id = params[:line_user_id]
    avatar_url = params[:avatar_url]

    # バリデーション
    if line_user_id.blank? || display_name.blank?
      render json: { success: false, error: "LINE情報が不正です" }
      return
    end

    user = find_or_create_line_user(line_user_id, avatar_url)

    # 初回ログイン時はニックネーム設定画面へ
    if user.nickname.blank?
      render json: {
        success: true,
        redirect_to_nickname_setup: true,
        user_id: user.id
      }
    else
      sign_in(user)
      render json: { success: true }
    end
  end

  def destroy
    sign_out(current_user) if current_user
    render json: { success: true }
  end

  private

  def find_or_create_line_user(line_user_id, display_name, avatar_url)
    User.find_or_create_by(line_user_id: line_user_id) do |user|
      user.display_name = display_name
      user.avatar_url = avatar_url
      # devise用の一時的な値（後で削除予定）
      user.email = "#{line_user_id}@line.temp"
      user.password = SecureRandom.hex(10)
    end
  end
end
