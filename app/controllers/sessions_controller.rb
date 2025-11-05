class SessionsController < ApplicationController
  # CSRF保護を無効化（LINE認証用）
  skip_before_action :verify_authenticity_token, only: [:line_callback]
  # Devise認証をスキップ
  skip_before_action :authenticate_user!, only: [:line_callback, :destroy]

  # LINE認証後のコールバック処理
  def line_callback
    begin
      # パラメータから認証情報を取得
      line_user_id = params[:line_user_id]
      display_name = params[:display_name]

      # バリデーション
      if line_user_id.blank? || display_name.blank?
        render json: { error: '認証情報が不正です' }, status: :bad_request
        return
      end

      user = User.find_or_create_by_line(line_user_id, display_name)

      if user.persisted?
        log_in(user)

        render json: {
          success: true,
          message: 'ログインが完了しました',
          redirect_url: checkin_page_checkinout_records_path
        }
      else
        render json: { error: 'ユーザー作成に失敗しました' }, status: :unprocessable_entity
      end

    rescue => e
      Rails.logger.error "LINE認証エラー: #{e.message}"
      render json: { error: 'システムエラーが発生しました' }, status: :internal_server_error
    end
  end

  # ログアウト処理
  def destroy
    if logged_in_line?
      # STEP 6で作成したメソッドを使用してログアウト
      log_out
      redirect_to root_path, notice: 'ログアウトしました'
    else
      redirect_to root_path, alert: '既にログアウトしています'
    end
  end

  def line_redirect
    # LINE認証への誘導処理
    # 例：LIFFアプリのURLにリダイレクト
    liff_url = "https://liff.line.me/#{ENV['LIFF_ID']}"
    redirect_to liff_url
  end
end