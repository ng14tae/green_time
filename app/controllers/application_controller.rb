class ApplicationController < ActionController::Base
  # devise用既存メソッド（段階的に削除予定）
  before_action :authenticate_user!
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user_line, :logged_in_line?

  def after_sign_in_path_for(resource)
    checkin_page_checkinout_records_path
  end

  # === LINE認証用セッション管理メソッド ===

  # ユーザーをログインさせる（LINE認証用）
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを取得（LINE認証用）
  def current_user_line
    @current_user_line ||= User.find(session[:user_id]) if session[:user_id]
  end

  # ログイン状態を確認（LINE認証用）
  def logged_in_line?
    current_user_line.present?
  end

  # ユーザーをログアウトさせる（LINE認証用）
  def log_out
    session.delete(:user_id)
    @current_user_line = nil
  end

  # ログインが必要なページの制御（LINE認証用）
  def require_line_login
    unless logged_in_line?
      # ブラウザの種類で分岐
      if request.user_agent&.include?("Line") || request.headers["X-Requested-With"] == "LIFF"
        # LINEブラウザの場合：ログインページへ
        redirect_to line_redirect_path
      else
        # 外部ブラウザの場合：LINE公式アカウント誘導ページへ
        redirect_to line_guide_path
      end
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :nickname, :display_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :nickname, :display_name ])
  end
end
