class LineSessionsController < ApplicationController
  skip_before_action :authenticate_user_with_line_support!

  def create
    begin
      line_user_id = params[:line_user_id]
      display_name = params[:display_name]
      avatar_url = params[:avatar_url]

      Rails.logger.info "LINE認証: line_user_id=#{line_user_id}, display_name=#{display_name}"

      # バリデーション
      if line_user_id.blank? || display_name.blank?
        render json: { success: false, error: "LINE情報が不正です" }
        return
      end

      user = find_or_create_line_user(line_user_id, display_name, avatar_url)

      if user.persisted?
        # セッション設定（ApplicationControllerのメソッドを使用）
        log_in_line(user)

        redirect_to checkin_page_checkinout_records_path, allow_other_host: false
      else
        Rails.logger.error "ユーザー作成失敗: #{user.errors.full_messages}"
        render json: {
          success: false,
          error: "ユーザー作成に失敗しました"
        }
      end

    rescue => e
      Rails.logger.error "LINE認証エラー: #{e.message}"
      render json: {
        success: false,
        error: "システムエラーが発生しました"
      }
    end
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
