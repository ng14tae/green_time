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
    session[:line_user_id] = user.line_user_id
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを取得（LINE認証用）
  def current_user_line
    if session[:line_user_id].present?
      @current_user_line ||= User.find_by(line_user_id: session[:line_user_id])
    end
  end

  # ログイン状態を確認（LINE認証用）
  def logged_in_line?
    current_user_line.present?
  end

  # ユーザーをログアウトさせる（LINE認証用）
  def log_out_line
    session.delete(:line_user_id)
    session.delete(:user_id)
    @current_user_line = nil
  end

  # 既存のcurrent_userメソッドとの統合
  def current_user
    # LINE認証ユーザーを優先
    current_user_line || super
  end

  # ログインが必要なページの制御（LINE認証用）
  def require_line_login
    unless logged_in_line?
      if request.user_agent&.include?("Line") || request.headers["X-Requested-With"] == "LIFF"
        redirect_to line_guide_path
      else
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
