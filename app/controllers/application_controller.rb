class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :authenticate_user_with_line_support!

  helper_method :current_user_line, :logged_in_line?

  def after_sign_in_path_for(resource)
    checkin_page_checkinout_records_path
  end

  # === LINE認証用セッション管理メソッド ===

  # ユーザーをログインさせる（LINE認証用）
  def log_in_line(user)
    session[:line_user_id] = user.line_user_id
    session[:user_id] = user.id
    session[:login_type] = "line"
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
    session.delete(:login_type)
    @current_user_line = nil
  end

  # 既存のcurrent_userメソッドとの統合
  def current_user
    # LINE認証ユーザーを優先
    current_user_line || super
  end

  def authenticate_user_with_line_support!
    if request.path == line_guide_path
      return
    end

    # LINE認証ユーザーがいればOK
    if logged_in_line?
      return
    end

    # Devise認証もチェック
    if defined?(Devise) && respond_to?(:user_signed_in?) && user_signed_in?
      return
    end

    redirect_to line_guide_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :nickname, :display_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :nickname, :display_name ])
  end
end
