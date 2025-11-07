class SessionsController < ApplicationController
    skip_before_action :authenticate_user_with_line_support! # 開発用に一時的にskip
  def create
    redirect_to root_path, notice: "テスト成功"
  end
end
