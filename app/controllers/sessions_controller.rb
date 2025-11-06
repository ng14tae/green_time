class SessionsController < ApplicationController
  def create
    redirect_to root_path, notice: "テスト成功"
  end
end
