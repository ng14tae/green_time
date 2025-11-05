class LineGuidesController < ApplicationController
  skip_before_action :authenticate_user!  # Deviseを無効化
  # skip_before_action :require_line_login  # LINE認証も無効化

  def show
  end
end
